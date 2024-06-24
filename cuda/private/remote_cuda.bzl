"""

remote_cuda - downloads a remote CUDA archive

"""

def _remote_cuda_impl(rctx):
    redist = rctx.read(Label(rctx.attr.json_path))
    repos = json.decode(redist)
    repos_to_define = dict()

    os = rctx.attr.platform.split("-")[0]
    arch = rctx.attr.platform.split("-")[1]
    major_version = rctx.attr.version.split(".")[0]
    minor_version = rctx.attr.version.split(".")[1]

    skip_keys = ["name", "license", "release_date"]
    for lib_name, lib_pkg_dict in repos.items():
        if lib_name in skip_keys:
            continue
        for lib_arch in repos[lib_name]:
            if "version" == lib_arch:
                #grab the version and continue
                version = repos[lib_name][lib_arch]
                major_version = version.split(".")[0]
                minor_version = version.split(".")[1]
                continue
            if lib_arch == rctx.attr.platform:
                url = rctx.attr.base_url + repos[lib_name][lib_arch]["relative_path"]
                rctx.download_and_extract(
                    url = url,
                    sha256 = repos[lib_name][rctx.attr.platform]["sha256"],
                    stripPrefix = url.split("/")[-1][:-7],
                    # Store the repository under a directory. We need to somehow include a BUILD.bazel file here too.
                    output = lib_name,
                )
                if lib_name == "nvcc":
                    rctx.symlink(Label("//cuda:templates/remote_cuda_module_nvcc.BUILD.tpl"), "{}/BUILD.bazel".format(lib_name))
                else:
                    rctx.symlink(Label("//cuda:templates/remote_cuda_module.BUILD.tpl"), "{}/BUILD.bazel".format(lib_name))

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

def _remote_cuda_single_impl(rctx):
    os = rctx.attr.platform.split("-")[0]
    arch = rctx.attr.platform.split("-")[1]

    major_version = rctx.attr.version.split(".")[0]
    minor_version = rctx.attr.version.split(".")[1]

    rctx.download_and_extract(
        url = rctx.attr.url,
        sha256 = rctx.attr.sha256,
        stripPrefix = rctx.attr.strip_prefix,
        # Store the repository under a directory. We need to somehow include a BUILD.bazel file here too.
    )
    if rctx.attr.build_file == None:
        if "nvcc" in rctx.attr.repo_name:
            rctx.symlink(Label("//cuda:templates/remote_cuda_module_nvcc.BUILD.tpl"), "BUILD.bazel")
        else:
            rctx.symlink(Label("//cuda:templates/remote_cuda_module.BUILD.tpl"), "BUILD.bazel")

    rctx.file("MODULE.bazel", content = "module(name = '{}')".format(rctx.attr.repo_name), executable = False)

remote_cuda_single = repository_rule(
    implementation = _remote_cuda_single_impl,
    attrs = {
        "repo_name": attr.string(mandatory = True),
        "platform": attr.string(mandatory = True),
        "version": attr.string(mandatory = True),
        "url": attr.string(mandatory = True),
        "sha256": attr.string(mandatory = True),
        "strip_prefix": attr.string(default = ""),
        "build_file": attr.label(),
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

    os = rctx.attr.platform.split("-")[0]
    arch = rctx.attr.platform.split("-")[1]
    major_version = rctx.attr.version.split(".")[0]
    minor_version = rctx.attr.version.split(".")[1]

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
    },
)
