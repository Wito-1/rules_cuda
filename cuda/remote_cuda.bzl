"""bzlmod extension that pulls in a specific cuda version"""

load("//cuda/private:remote_cuda.bzl", "remote_cuda", "remote_cuda_single", "remote_cuda_toplevel", "remote_cuda_cross_platform")
load("@bazel_skylib//lib:modules.bzl", "modules")

cuda_toolkit = tag_class(attrs = {
    "name": attr.string(
        doc = "Name for the toolchain repository",
        default = "cuda",
    ),
    "version": attr.string(
        doc = "Which redistrib_*_.json version to load, dictating which URLs to download",
        mandatory = True,
    ),
    "platform": attr.string(
        doc = "Which platform to download in the form of <os>-<arch>.",
        mandatory = True,
    ),
    "redistrib_path": attr.label(
        default = None,
        doc = "Path to the redistrib file. Should be provided if the version file doesn't exist in this repo",
    ),
    "base_url": attr.string(
        default = "https://developer.download.nvidia.com/compute/cuda/redist/",
        doc = "Base URL to prepend URLs in the redistrib_file",
    )
})


def _cuda_toolkit_impl(mctx):
    for mod in mctx.modules:
#        if not mod.is_root:
#            fail("Only the root module may override the path for the local cuda toolchain")
        for arg in mod.tags.install:
            redistrib_path = arg.redistrib_path or Label("//cuda/redistrib:redistrib_{}.json".format(arg.version))

            # Downloads all cuda dependencies in one external repository
            remote_cuda(
                name = arg.name,
                repo_name = arg.name,
                version = arg.version,
                platform = arg.platform,
                json_path = redistrib_path,
                base_url = arg.base_url,
            )

toolchain = module_extension(
    implementation = _cuda_toolkit_impl,
    tag_classes = {"install": cuda_toolkit},
)
cuda_cross_platform_alias = tag_class(attrs = {
    "name": attr.string(
        doc = "Name for the repository to reference",
        default = "cuda",
    ),
    "cuda_repositories": attr.label_keyed_string_dict(
        doc = "List of platform constraints, ending with `:<os>-<arch>`",
        mandatory = True,
    ),
})

def _cuda_toolkit_parallel_impl(mctx):
    for mod in mctx.modules:
#        if not mod.is_root:
#            fail("Only the root module may override the path for the local cuda toolchain")
        cuda_libs = []
        for arg in mod.tags.install:
            redistrib_path = arg.redistrib_path or Label("//cuda/redistrib:redistrib_{}.json".format(arg.version))
            redist = mctx.read(Label(redistrib_path))
            repos = json.decode(redist)

            skip_keys = ["name", "license", "release_date"]
            for lib_name, lib_pkg_dict in repos.items():
                if lib_name in skip_keys:
                    continue
                for lib_arch in repos[lib_name]:
                    if "version" == lib_arch:
                        version = repos[lib_name][lib_arch]
                        major_version = version.split(".")[0]
                        minor_version = version.split(".")[1]
                        continue
                    if lib_arch == arg.platform:
                        url = arg.base_url + repos[lib_name][lib_arch]["relative_path"]
                        sha256 = repos[lib_name][lib_arch]["sha256"]
                        strip_prefix = url.split("/")[-1][:-7]
                        name = "{}-{}".format(lib_name, arg.platform)
                        remote_cuda_single(
                            name = name,
                            repo_name = lib_name,
                            version = version,
                            platform = arg.platform,
                            url = url,
                            sha256 = sha256,
                            strip_prefix = strip_prefix,
                        )
                        cuda_libs.append(lib_name)
            remote_cuda_toplevel(
                name = arg.name,
                repo_name = arg.name,
                platform = arg.platform,
                version = arg.version,
                cuda_libs = cuda_libs
            )

#        for arg in mod.tags.install_cross_platform:
#            remote_cuda_cross_platform(name = arg.name, platforms = arg.platforms)

    return modules.use_all_repos(mctx)

toolchain_parallel = module_extension(
    implementation = _cuda_toolkit_parallel_impl,
    tag_classes = {
        "install": cuda_toolkit,
        "install_toplevel": cuda_toolkit,
#        "install_cross_platform": cuda_cross_platform_alias,
    },
)

def _cuda_toolkit_cross_platform_impl(mctx):
    for mod in mctx.modules:
#        if not mod.is_root:
#            fail("Only the root module may override the path for the local cuda toolchain")
#        cuda_libs = []
        for arg in mod.tags.install:
#            remote_cuda_cross_platform(name = arg.name, platforms = arg.platforms)
#            for label, platform in arg.cuda_repositories.items():
#                print("__________________________________________________")
#                print(label.name)
#                print(arch)
#                print(label.repo_name)
#                print("__________________________________________________")
            remote_cuda_cross_platform(name = arg.name, cuda_platform_repositories = arg.cuda_repositories)
    return modules.use_all_repos(mctx)

toolchain_cross_platform = module_extension(
    implementation = _cuda_toolkit_cross_platform_impl,
    tag_classes = {
        "install": cuda_cross_platform_alias,
    },
)
