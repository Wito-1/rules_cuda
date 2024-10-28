"""bzlmod extension that pulls in a specific cuda version"""

load("//cuda/private:remote_cuda_platform_library_repository.bzl", "cuda_platform_library")
load("//cuda/private:remote_cuda_platform_repository.bzl", "cuda_platform")
load("//cuda/private:remote_cuda_cross_platform_alias.bzl", "cuda_cross_platform_alias")
load("//cuda/private:remote_cuda_cross_platform_toolchain_alias.bzl", "cuda_cross_platform_toolchain_alias")

_REDISTRIB_BASE_URL = "https://developer.download.nvidia.com/compute/cuda/redist"

extension_args = tag_class(attrs = {
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
    )
})

def _cuda_cross_platform_impl(mctx):
    for mod in mctx.modules:
        if not mod.is_root:
            fail("Only the root module may override the path for the local cuda toolchain")

        # Each cuda library + platform is its own repository
        cuda_platform_libraries = {}

        # For each platform, there's a toplevel repository selecting the library + platform repositories.
        cuda_platform_repositories = {}

        for arg in mod.tags.install:
            # Rearrange the provided arguments into a dictionary keyed by platform. Eg. dict["linux-x86_64"]["url"] = "https//..."
            platform_args_dict = _get_platform_args_dict(arg)
            print(platform_args_dict)

            for platform, args in platform_args_dict.items():

                cuda_platform_libraries[platform] = []

                # Use user-provided url attribute if they provided it, otherwise default to default download template
                redistrib_url = platform_args_dict[platform].get("url", arg.default_download_template.format(platform_args_dict[platform]["version"]))

                # Downloads the redistributable file and organizes it into a dictionary
                redistrib_file = "{}-{}.json".format(platform, arg.version)
                mctx.download(redistrib_url, output=redistrib_file, sha256=arg.sha256)

                cuda_redistrib_dict = _redistrib_parse(
                    platform,
                    platform_args_dict[platform]["version"],
                    mctx.read(redistrib_file),
                )

                # TODO: ideally we'd be able to to make download_info_dict into a dictionary that can be used with cuda_platform_library with **args
                for lib_name, download_info_dict in cuda_redistrib_dict.items():
                    # Create a repository with the name: <name providided by user>-<platform>-<cuda library name from redistrib>
                    # eg. cuda-linux-x86_64-cublas
                    # TODO fix this naming for uniqueness
                    #name = "{}-{}-{}".format(arg.name, platform, lib_name)
                    name = "{}-{}".format(lib_name, platform)
                    print("######################################################")
                    print("Creating Repository: {}".format(name))
                    print("######################################################")
                    cuda_platform_library(
                        name = name,
                        repo_name = lib_name,
#                        version = args["version"],
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
#                    repo_name = arg.name,
                    platform = platform,
#                    version = platform_args_dict[platform]["version"],
#                    cuda_platform_library = cuda_platform_libraries[platform],
                )

                entry = {"{}".format(name): platform}
                print("Updating with: {}".format(entry))
                cuda_platform_repositories.update(entry)

            # Create an overarching library with the name provided by the user
            # that are aliases containing "select()" statements to the "platform" repositories
            print(arg.name)
            print(cuda_platform_repositories)
#            print(str(Label("@cuda-linux-x86_64")))
#            print(mctx.extension_repo_label("@cuda-linux-x86_64"))
            cuda_cross_platform_alias(
                name = arg.name,
                cuda_platform_repositories = cuda_platform_repositories,
            )
#
#            # Create a toolchain alias target to separate from other repos
            cuda_cross_platform_toolchain_alias(
                name = "{}_toolchain".format(arg.name),
                cuda_platform_repositories = cuda_platform_repositories,
            )

cuda_cross_platform = module_extension(
    implementation = _cuda_cross_platform_impl,
    tag_classes = {
        "install": extension_args,
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

def _redistrib_parse(platform, version, redistrib_file_contents):
    """Grab the URLS and sha256 of the version and archictecture

    Returns a dictionary in the form:
    lib_name:
      url: 
      major_version:
      minor_version:

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
                    url = _REDISTRIB_BASE_URL + repos[lib_name][lib_arch]["relative_path"]
                    module_info[lib_name]["url"] = url
                    module_info[lib_name]["sha256"] = repos[lib_name][platform]["sha256"]
                    module_info[lib_name]["strip_prefix"] = url.split("/")[-1][:-7]
    return module_info
