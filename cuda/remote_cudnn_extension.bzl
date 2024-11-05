"""bzlmod extension that pulls in a specific cudnn versions"""

load("//cuda/private:utils.bzl", "get_versions", "get_os_arch", "get_base_url", "get_platform_args_dict", "redistrib_parse")
load("//cuda/private:remote_cuda_platform_library_repository.bzl", "cuda_platform_library")
load("//cuda/private:remote_cuda_platform_repository.bzl", "cuda_platform")
load("//cuda/private:remote_cuda_cross_platform_alias.bzl", "cuda_cross_platform_alias")

_REDISTRIB_BASE_URL = "https://developer.download.nvidia.com/compute/cudnn/redist"

extension_attr = {
    "name": attr.string(
        doc = "Name for the toolchain repository",
        default = "cuda",
    ),
    "version": attr.string_dict(
        doc = "Which redistrib_*_.json version to load, dictating which URLs to download",
        mandatory = True,
    ),
    "url": attr.string_dict(
        default = {},
        doc = "Optional URL to override default download location",
    ),
    "sha256": attr.string(
        default = "",
        doc = "sha256 of the redistributable file",
    ),
    "default_download_template": attr.string(
        default = _REDISTRIB_BASE_URL + "/redistrib_{}.json",
        doc = "Default redistributable download location, inserting the version in {}",
    ),
    "cuda_variant": attr.string_dict(
        doc = "Per-platform cuda variants",
        mandatory = True,
    ),
}

def _core_cross_platform_impl(mctx, arg):
    # Each cuda library + platform is its own repository
    cuda_platform_libraries = {}

    # For each platform, there's a toplevel repository selecting the library + platform repositories.
    cuda_platform_repositories = {}

    # Rearrange the provided arguments into a dictionary keyed by platform. Eg. dict["linux-x86_64"]["url"] = "https//..."
    platform_args_dict = get_platform_args_dict(arg)

    for platform, args in platform_args_dict.items():
        cuda_platform_libraries[platform] = []

        # Use user-provided url attribute if they provided it, otherwise default to default download template
        redistrib_url = platform_args_dict[platform].get("url", arg.default_download_template.format(platform_args_dict[platform]["version"]))

        # Downloads the redistributable file and organizes it into a dictionary
        redistrib_file = "{}-{}.json".format(platform, arg.version[platform])
        mctx.download(redistrib_url, output=redistrib_file, sha256=arg.sha256)

        _redistrib_args = {
          "platform": platform,
          "version": platform_args_dict[platform]["version"],
          "redistrib_file_contents": mctx.read(redistrib_file),
          "base_url": get_base_url(arg.default_download_template),
          "cuda_variant": args["cuda_variant"],
        }
        
        cuda_redistrib_dict = redistrib_parse(**_redistrib_args)

        for lib_name, download_info_dict in cuda_redistrib_dict.items():
            # Create a repository with the name: <cuda library name from redistrib>-<platform>-<extension name providided by user>
            # eg. cublas-linux-x86_64-cuda

            name = "{}-{}-{}".format(lib_name, platform, arg.name)

            # TODO: Maybe rename this?
            cuda_platform_library(
                name = name,
                repo_name = lib_name,
                sha256 = download_info_dict["sha256"],
                url = download_info_dict["url"],
                strip_prefix = download_info_dict["strip_prefix"],
                cuda_library_build_file_template = Label("//cuda:templates/cuda_platform_library_v2.BUILD.tpl"),
            )
            cuda_platform_libraries[platform].append(lib_name)

        # Create a "platform" repository that brings together the "platform-library" repositories
        # eg. cudnn-linux-x86_64
        name = "{}-{}".format(arg.name, platform)
        cuda_platform(
            name = name,
            platform = "{}-{}".format(platform, arg.name),
            cuda_platform_build_file_template = Label("//cuda:templates/cuda_platform_repository_v2.BUILD.tpl"),
        )

        # TODO: we should be able to put the label to the target(s) exactly.
        cuda_platform_repositories.update({"@{}".format(name): platform})

    # Create an overarching library with the name provided by the user
    # that are aliases containing "select()" statements to the "platform" repositories
    cuda_cross_platform_alias(
        name = arg.name,
        cuda_platform_repositories = cuda_platform_repositories,
        cuda_libraries = ["headers", "shared_libs", "shared_stub_libs", "static_libs", arg.name],
    )

def _cudnn_cross_platform_impl(mctx):
    for mod in mctx.modules:
        for arg in mod.tags.install:
            _core_cross_platform_impl(mctx, arg)

cudnn_cross_platform = module_extension(
    implementation = _cudnn_cross_platform_impl,
    tag_classes = {
        "install": tag_class(attrs = extension_attr),
    },
)
