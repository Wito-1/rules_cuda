"""bzlmod extension that pulls in a specific cuda version"""

load("//cuda/private:remote_cuda_platform_library_repository.bzl", "cuda_platform_library")
load("//cuda/private:remote_cuda_platform_repository.bzl", "cuda_platform")
load("//cuda/private:remote_cuda_platform_toolchain_repository.bzl", "cuda_platform_toolchain")
load("//cuda/private:remote_cuda_cross_platform_alias.bzl", "cuda_cross_platform_alias")
load("//cuda/private:remote_cuda_cross_platform_toolchain_alias.bzl", "cuda_cross_platform_toolchain_alias")

_REDISTRIB_BASE_URL = "https://developer.download.nvidia.com/compute/cuda/redist"
_CUDNN_REDISTRIB_BASE_URL = "https://developer.download.nvidia.com/compute/cudnn/redist"

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
    "toolchain": attr.bool(
        default = False,
        doc = "Set to True if the extension needs an nvcc toolchain definition & aliases",
    ),
    "default_download_template": attr.string(
        default = _REDISTRIB_BASE_URL + "/redistrib_{}.json",
        doc = "Default redistributable download location, inserting the version in {}",
    )
}

cudnn_extension_attr = extension_attr | {
    "cuda_variant": attr.string_dict(
        doc = "Per-platform cuda variants",
        mandatory = True,
    ),
    "default_download_template": attr.string(
        default = _CUDNN_REDISTRIB_BASE_URL + "/redistrib_{}.json",
        doc = "Default redistributable download location, inserting the version in {}",
    )
}

def _get_base_url(url):
    # Split the URL by '/' and remove the last segment (the file name)
    parts = url.split('/')
    directory_url = "/".join(parts[:-1])  # Excludes the last part
    return directory_url

def _cross_platform_impl_wrapper(mctx, arg):
    # Each cuda library + platform is its own repository
    cuda_platform_libraries = {}

    # For each platform, there's a toplevel repository selecting the library + platform repositories.
    cuda_platform_repositories = {}
    cuda_platform_toolchain_repositories = {}

    # Rearrange the provided arguments into a dictionary keyed by platform. Eg. dict["linux-x86_64"]["url"] = "https//..."
    platform_args_dict = _get_platform_args_dict(arg)

    for platform, args in platform_args_dict.items():
        cuda_platform_libraries[platform] = []

        # Use user-provided url attribute if they provided it, otherwise default to default download template
        redistrib_url = platform_args_dict[platform].get("url", arg.default_download_template.format(platform_args_dict[platform]["version"]))

        # Downloads the redistributable file and organizes it into a dictionary
        redistrib_file = "{}-{}.json".format(platform, arg.version)
        mctx.download(redistrib_url, output=redistrib_file, sha256=arg.sha256)

        _redistrib_args = {
          "platform": platform,
          "version": platform_args_dict[platform]["version"],
          "redistrib_file_contents": mctx.read(redistrib_file),
          "base_url": _get_base_url(arg.default_download_template),
        }
        
        if "cuda_variant" in args:
          _redistrib_args.update({"cuda_variant": args["cuda_variant"]})

        cuda_redistrib_dict = _redistrib_parse(**_redistrib_args)

        # TODO: ideally we'd be able to to make download_info_dict into a dictionary that can be used with cuda_platform_library with **args
        for lib_name, download_info_dict in cuda_redistrib_dict.items():
            # Create a repository with the name: <name providided by user>-<platform>-<cuda library name from redistrib>
            # eg. cuda-linux-x86_64-cublas

            # TODO fix this naming for uniqueness
            name = "{}-{}-{}".format(lib_name, platform, arg.name)

            cuda_platform_library(
                name = name,
                repo_name = lib_name,
                sha256 = download_info_dict["sha256"],
                url = download_info_dict["url"],
                strip_prefix = download_info_dict["strip_prefix"],
            )
            cuda_platform_libraries[platform].append(lib_name)

        # Create a "platform" repository that brings together the "platform-library" repositories
        # eg. cuda-linux-x86_64 (contains cuda-linux-x86_64)
        name = "{}-{}".format(arg.name, platform)
        cuda_platform(
            name = name,
            platform = "{}-{}".format(platform, arg.name),
        )

        # TODO: we should be able to put the label to the target(s) exactly.
        cuda_platform_repositories.update({"@{}".format(name): platform})

        if arg.toolchain:
            os, arch = _get_os_arch(platform)
            major, minor = _get_versions(platform_args_dict[platform]["version"])

            # Creates a @cuda-linux-x86_64_toolchain repository
            name = "{}_toolchain".format(name)
            cuda_platform_toolchain(
                name = name,
                platform = "{}-{}".format(platform, arg.name),
                major = major,
                minor = minor,
                arch = arch,
                os = os,
                nvcc_repository = "@cuda_nvcc-{}-{}".format(platform, arg.name),
            )
            cuda_platform_toolchain_repositories.update({"@{}".format(name): platform})

    # Create an overarching library with the name provided by the user
    # that are aliases containing "select()" statements to the "platform" repositories
    cuda_cross_platform_alias(
        name = arg.name,
        cuda_platform_repositories = cuda_platform_repositories,
    )

    if arg.toolchain:
        cuda_cross_platform_toolchain_alias(
            name = "{}_toolchain".format(arg.name),
            cuda_platform_repositories = cuda_platform_toolchain_repositories,
        )

def _cuda_cross_platform_impl(mctx):
    for mod in mctx.modules:
#        if not mod.is_root:
#            fail("Only the root module may override the path for the local cuda toolchain")

        for arg in mod.tags.install:
            _cross_platform_impl_wrapper(mctx, arg)

        for arg in mod.tags.install_cudnn:
            _cross_platform_impl_wrapper(mctx, arg)

cuda_cross_platform = module_extension(
    implementation = _cuda_cross_platform_impl,
    tag_classes = {
        "install": tag_class(attrs = extension_attr),
        "install_cudnn": tag_class(attrs = cudnn_extension_attr),
    },
)

def _get_platform_args_dict(args):
    # Go through each argument passed to the module extension and convert it 
    # into a dictionary form for each platform.

    out_args = {}
    for arg in dir(args):
        arg_value = getattr(args, arg)
        if type(arg_value) == type({}):
            for platform, value in arg_value.items():
                if platform not in out_args:
                    out_args[platform] = {}
                out_args[platform][arg] = value
    return out_args

def _get_versions(version_string):
    major_version = version_string.split(".")[0]
    minor_version = version_string.split(".")[1]
    return (major_version, minor_version)

def _get_os_arch(platform):
    os = platform.split("-")[0]
    arch = platform.split("-")[1]
    return (os, arch)

def _redistrib_parse(platform, version, redistrib_file_contents, base_url=_REDISTRIB_BASE_URL, cuda_variant=None):
    """Grab the URLS and sha256 of the version and archictecture

    Returns a dictionary in the form:
    lib_name:
      url: 
      major_version:
      minor_version:
      cuda_variant: optional parameter for nested cuda variant in redistributable (eg. cudnn cuda11 and cuda12 subtree)

    """
    os, arch = _get_os_arch(platform)
    major_version, minor_version = _get_versions(version)

    repos = json.decode(redistrib_file_contents)

    skip_keys = ["name", "license", "release_date"]

    module_info = {}
    for lib_name, lib_pkg_dict in repos.items():
        if lib_name in skip_keys:
            continue
        if platform in repos[lib_name]:
            module_info[lib_name] = {}
            for lib_arch in lib_pkg_dict:
                if "version" == lib_arch:
                    #grab the version and continue
                    version = repos[lib_name][lib_arch]
                    module_major, module_minor = _get_versions(version)
                    module_info[lib_name]["major_version"] = module_major
                    module_info[lib_name]["minor_version"] = module_minor
                    continue
                if lib_arch == platform:
                    if cuda_variant:
                        url = base_url + "/" + repos[lib_name][platform][cuda_variant]["relative_path"]
                        module_info[lib_name]["url"] = url
                        module_info[lib_name]["sha256"] = repos[lib_name][platform][cuda_variant]["sha256"]
                    else:
                        url = base_url + "/" + repos[lib_name][platform]["relative_path"]
                        module_info[lib_name]["url"] = url
                        module_info[lib_name]["sha256"] = repos[lib_name][platform]["sha256"]

                    module_info[lib_name]["strip_prefix"] = url.split("/")[-1][:-7]
    return module_info
