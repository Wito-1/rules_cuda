"""

remote_cuda - downloads a remote CUDA archive

"""


# Create a repository rule that ties together all the cuda libraries for a platform

def _cuda_platform_toolchain_impl(rctx):
    cuda_platform_toolchain_template = Label(rctx.attr.cuda_platform_toolchain_template)
    major_version, minor_version = _get_version(rctx.attr.version)
    os, arch = _get_os_arch(rctx.attr.platform)
    rctx.template(
        "BUILD.bazel",
        cuda_platform_toolchain_template,
        substitutions = {
            "{{platform}}": rctx.attr.platform,
            "{{repo}}": rctx.attr.name,
            "{{major}}": major_version,
            "{{minor}}": minor_version,
            "{{os}}": os,
        },
    )

cuda_platform_toolchain = repository_rule(
    implementation = _cuda_platform_toolchain_impl,
    attrs = {
        "version": attr.string(mandatory = True),
        "platform": attr.string(mandatory = True),
        "cuda_platform_toolchain_template" = attr.Label(default = Label("//cuda:templates/cuda_platform_toolchain_template.BUILD.tpl")),
    },
)













def _get_versions(version_string):
    major_version = version_string.split(".")[0]
    minor_version = version_string.split(".")[1]
    return (major_version, minor_version)

def _get_os_arch(platform):
    os = platform.split("-")[0]
    arch = platform.split("-")[1]
    return (os, arch)

def _redistrib_parser(version, platform, base_url, redistrib_file):
    """Grab the URLS and sha256 of the version and archictecture

    Returns a dictionary in the form:
    lib_name:
      url: 
      sha256:
      major_version:
      minor_version:

    """
    os, arch = _get_os_arch(platform)
    major_version, minor_version = _get_versions(version)

    redist = rctx.read(Label(rctx.attr.json_path))
    repos = json.decode(redist)

    skip_keys = ["name", "license", "release_date"]

    something = {}
    for lib_name, lib_pkg_dict in repos.items():
        if lib_name in skip_keys:
            continue
        something[lib_name] = {}
        for lib_arch in lib_pkg_dict:
            if "version" == lib_arch:
                #grab the version and continue
                version = repos[lib_name][lib_arch]
                something[lib_name]["major_version"] = version.split(".")[0]
                something[lib_name]["minor_version"] = version.split(".")[1]
                continue
            if lib_arch == platform:
                something[lib_name]["url"] = base_url + repos[lib_name][lib_arch]["relative_path"]
                something[lib_name]["sha256"] = repos[lib_name][platform]["sha256"]
    return something


def _remote_cuda_impl(rctx):
    os = rctx.attr.platform.split("-")[0]
    arch = rctx.attr.platform.split("-")[1]
    major_version, minor_version = _get_version(rctx.attr.version)

    redistrib_dict = _redistrib_parser(
        rctx.attr.version,
        rctx.attr.platform,
        rctx.attr.base_url,
        Label(rctx.attr.json_path)
    )
    # Download and extract each archive from the redistributable.
    for lib_name, lib_info in redistrib_dict.keys():
        rctx.download_and_extract(
            url = lib_info["url"],
            sha256 = lib_info["sha256"],
            stripPrefix = lib_info["url"].split("/")[-1][:-7],
            output = lib_name,
        )

        #TODO: We probably need to relook at these BUILD.bazel files.
        # Handle nvcc a little differently because we need to define the toolchains with it.
        if lib_name == "nvcc":
            rctx.symlink(Label("//cuda:templates/remote_cuda_module_nvcc.BUILD.tpl"), "{}/BUILD.bazel".format(lib_name))
        else:
            rctx.template(
                "{}/BUILD.bazel".format(lib_name),
                Label("//cuda:templates/remote_cuda_module.BUILD.tpl"),
                substitutions = {
                    "{{MODULE_NAME}}": lib_name,
                },
            )

    # Output a toplevel BUILD.bazel file
    rctx.template(
        "BUILD.bazel",
        Label("//cuda:templates/remote_cuda.BUILD.tpl"),
        substitutions = {
            "{{platform}}": rctx.attr.platform,
            "{{repo_name}}": rctx.attr.repo_name,
        },
    )

    rctx.template(
        "toolchain/BUILD.bazel",
        Label("//cuda:templates/remote_toolchain_nvcc.BUILD.tpl"),
        substitutions = {
            "{{platform}}": rctx.attr.platform,
            "{{repo}}": rctx.attr.repo_name,
            "{{major}}": major_version,
            "{{minor}}": minor_version,
            "{{os}}": os,
            "{{arch}}": arch,
        },
    )

    rctx.file("WORKSPACE.bazel", content = "workspace({})".format(rctx.attr.name), executable = False)
    rctx.file("WORKSPACE.bzlmod", content = "workspace({})".format(rctx.attr.name), executable = False)

remote_cuda = repository_rule(
    implementation = _remote_cuda_impl,
    attrs = {
        "repo_name": attr.string(mandatory = True),
        "platform": attr.string(mandatory = True),
        "version": attr.string(mandatory = True),
        "json_path": attr.label(mandatory = True),
        "base_url": attr.string(default = "https://developer.download.nvidia.com/compute/cuda/redist/"),
    },
)


def _remote_cuda_toplevel_impl(rctx):
    # Output a toplevel BUILD.bazel file
    rctx.template(
        "BUILD.bazel",
        Label("//cuda:templates/remote_cuda_parallel.BUILD.tpl"),
        substitutions = {
            "{{platform}}": rctx.attr.platform,
        },
    )

    os, arch = _get_os_arch(rctx.attr.platform)
    major_version, minor_version = _get_versions(rctx.attr.version)

    if "sbsa" in arch:
        replace_dict = {"@platforms//cpu:{{arch}}": "@rules_cuda//cuda:sbsa"}
    else:
        replace_dict = {"{{arch}}": arch}

    rctx.template(
        "toolchain/BUILD.bazel",
        Label("//cuda:templates/remote_toolchain_nvcc_parallel.BUILD.tpl"),
        substitutions = replace_dict | {
            "{{platform}}": rctx.attr.platform,
            "{{repo}}": rctx.attr.name,
            "{{major}}": major_version,
            "{{minor}}": minor_version,
            "{{os}}": os,
        },
    )

    bazel_deps = ["bazel_dep(name='{}-{}')".format(lib, rctx.attr.platform) for lib in rctx.attr.cuda_libs]

    content = "module(name = '{}')\n".format(rctx.attr.repo_name)
    content += "\n".join(bazel_deps)
    rctx.file("MODULE.bazel", content, executable = False)

remote_cuda_toplevel = repository_rule(
    implementation = _remote_cuda_toplevel_impl,
    attrs = {
        "repo_name": attr.string(mandatory = True),
        "platform": attr.string(mandatory = True),
        "version": attr.string(mandatory = True),
        "cuda_libs": attr.string_list(mandatory=True), # List of cuda library repositories to register in the module.bazle file.
    },
)

def _remote_cuda_cross_platform_impl(rctx):
    # Reads in the template file
    build_template = rctx.read(Label("//cuda:templates/remote_cuda_cross_platform_toplevel.BUILD.tpl"))
    out_lines = []
    for line in build_template.split("\n"):
        # Expand to list a select from each platform input
        if "{{PLATFORM_CONSTRAINT}}" in line:
            for label, platform in rctx.attr.cuda_platform_repositories.items():
                platform_line = line.replace("{{PLATFORM_REPO}}", "@{}".format(label.repo_name))
                out_lines.append(platform_line.replace("{{PLATFORM_CONSTRAINT}}", "@rules_cuda//cuda:{platform}.constraint".format(platform=platform)))
            continue
        out_lines.append(line)
    rctx.file("BUILD.bazel", content = "\n".join(out_lines))
    rctx.file("cuda/BUILD.bazel", content = "")
    rctx.symlink(Label("//cuda:templates/defs.bzl.tpl"), "cuda/defs.bzl")


remote_cuda_cross_platform = repository_rule(
    implementation = _remote_cuda_cross_platform_impl,
    attrs = {
        "cuda_platform_repositories": attr.label_keyed_string_dict(
            doc = "List of platforms to create alias cuda rules for", 
            mandatory = True,
        ),
        "nvcc_toolchain_build_file": attr.label(
            allow_single_file = True,
            default = Label("//cuda:templates/remote_cuda_module_nvcc.BUILD.tpl"), 
        ),
        "cuda_library_build_file_template": attr.label(
            allow_single_file = True,
            default = Label("//cuda:templates/cuda_platform_library.BUILD.tpl"), 
        ),
    },
)
