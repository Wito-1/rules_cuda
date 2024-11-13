"""Utility functions used across repository rules"""

def get_versions(version_string):
    major_version = version_string.split(".")[0]
    minor_version = version_string.split(".")[1]
    return (major_version, minor_version)

def get_os_arch(platform):
    os = platform.split("-")[0]
    arch = platform.split("-")[1]
    return (os, arch)

def get_base_url(url):
    # Split the URL by '/' and remove the last segment (the file name)
    parts = url.split('/')
    directory_url = "/".join(parts[:-1])  # Excludes the last part
    return directory_url

def get_platform_args_dict(args):
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

def redistrib_parse(platform, version, redistrib_file_contents, base_url, cuda_variant=None):
    """Grab the URLS and sha256 of the version and archictecture

    Returns a dictionary in the form:
    lib_name:
      url: 
      sha256:
      strip_prefix:
      major_version:
      minor_version:
    """
    os, arch = get_os_arch(platform)
    major_version, minor_version = get_versions(version)

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
                    module_major, module_minor = get_versions(version)
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
