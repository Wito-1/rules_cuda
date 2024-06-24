load("//cuda/private:providers.bzl", "CudaToolchainConfigInfo", "CudaToolkitInfo")
load("//cuda/private:toolchain_config_lib.bzl", "config_helper")

def _cuda_toolchain_impl(ctx):
    cuda_toolchain_config = ctx.attr.toolchain_config[CudaToolchainConfigInfo]
    selectables_info = config_helper.collect_selectables_info(cuda_toolchain_config.action_configs + cuda_toolchain_config.features)
    must_have_selectables = []
    for name in must_have_selectables:
        if not config_helper.is_configured(selectables_info, name):
            fail(name, "is not configured (not exists) in the provided toolchain_config")

    artifact_name_patterns = {}
    for pattern in cuda_toolchain_config.artifact_name_patterns:
        artifact_name_patterns[pattern.category_name] = pattern

    return [
        platform_common.ToolchainInfo(
            name = ctx.label.name,
            compiler_executable = ctx.attr.compiler_executable,
            all_files = ctx.attr.compiler_files.files if ctx.attr.compiler_files else depset(),
            selectables_info = selectables_info,
            artifact_name_patterns = artifact_name_patterns,
            cuda_toolkit = cuda_toolchain_config.cuda_toolkit,
        ),
    ]

cuda_toolchain = rule(
    doc = """This rule consumes a `CudaToolchainConfigInfo` and provides a `platform_common.ToolchainInfo`, a.k.a, the CUDA Toolchain.""",
    implementation = _cuda_toolchain_impl,
    attrs = {
        "toolchain_config": attr.label(
            mandatory = True,
            providers = [CudaToolchainConfigInfo],
            doc = "A target that provides a `CudaToolchainConfigInfo`.",
        ),
        "compiler_executable": attr.string(mandatory = True, doc = "The path of the main executable of this toolchain."),
        "compiler_files": attr.label(allow_files = True, cfg = "exec", doc = "The set of files that are needed when compiling using this toolchain."),
        "_cc_toolchain": attr.label(default = "@bazel_tools//tools/cpp:current_cc_toolchain"),
    },
)
CPP_TOOLCHAIN_TYPE = "@bazel_tools//tools/cpp:toolchain_type"
CUDA_TOOLCHAIN_TYPE = "//cuda:toolchain_type"


def _remote_cuda_impl(rctx):
    redist = rctx.read(Label(rctx.attr.json_path))
    repos = json.decode(redist)
    repos_to_define = dict()
    base_url = rctx.attr.base_url

    for key in repos:
        if key == "release_date":
            continue
        for arch in repos[key]:
            if arch == "name" or arch == "license" or arch == "version":
                continue
            repo_name = key + "-%s" % arch
            repos_to_define[repo_name] = {
                "repo_rule": "http_archive",
                "name": repo_name,
                "sha256": repos[key][arch]["sha256"],
                "url": base_url + repos[key][arch]["relative_path"],
            }

            rctx.download_and_extract(
                url = repos_to_define[repo_name]["url"],
                sha256 = repos_to_define[repo_name]["sha256"],
                stripPrefix = repos_to_define[repo_name]["strip_prefix"],
                output = key,
            )

            rctx.symlink(Label("//cuda:templates/remote_cuda_module.BUILD.tpl"), "{}/BUILD.bazel".format(key))

    # 
    # Output a toplevel BUILD.bazel file
    rctx.template(
        path = "BUILD.bazel",
        template = Label("//cuda:templates/remote_cuda.BUILD.tpl"),
        substitutions = {
            "{platform}": "linux-x86_64",  #TODO this should be a variable
            "{repo_name}": rctx.attr.repo_name,
        },
    )

    rctx.template(
        path = "toolchain/BUILD.bazel",
        template = Label("//cuda:templates/remote_toolchain_nvcc.BUILD.tpl"),
        substitutions = {
            "{platform}": "linux-x86_64",  #TODO this should be a variable
            "{repo}": rctx.attr.repo_name,
            "{major}": rctx.attr.repo_name,
            "{minor}": rctx.attr.repo_name,
            "{os}": rctx.attr.repo_name,
            "{arch}": rctx.attr.repo_name,
        },
    )

_remote_cuda = repository_rule(
    implementation = _remote_cuda_impl,
    attrs = {
        "repo_name": attr.string(default = "remote_cuda"),
        "base_url": attr.string(default = "https://developer.download.nvidia.com/compute/cuda/redist/"),
        "json_path": attr.string(mandatory = True),
    },
)

# buildifier: disable=unused-variable
def use_cpp_toolchain(mandatory = True):
    """Helper to depend on the C++ toolchain.

    Notes:
        Copied from [toolchain_utils.bzl](https://github.com/bazelbuild/bazel/blob/ac48e65f70/tools/cpp/toolchain_utils.bzl#L53-L72)
    """
    return [CPP_TOOLCHAIN_TYPE]

def use_cuda_toolchain():
    """Helper to depend on the CUDA toolchain."""
    return [CUDA_TOOLCHAIN_TYPE]

def find_cuda_toolchain(ctx):
    """Helper to get the cuda toolchain from context object.

    Args:
        ctx: The rule context for which to find a toolchain.

    Returns:
        A `platform_common.ToolchainInfo` that wraps around the necessary information of a cuda toolchain.
    """
    return ctx.toolchains[CUDA_TOOLCHAIN_TYPE]

def find_cuda_toolkit(ctx):
    """Finds the CUDA toolchain.

    Args:
        ctx: The rule context for which to find a toolchain.

    Returns:
        A CudaToolkitInfo.
    """
    return ctx.toolchains[CUDA_TOOLCHAIN_TYPE].cuda_toolkit[CudaToolkitInfo]

CUDA_VERSIONS_JSON = {
    "11.4.4": "//cuda:redistrib/redistrib_11.4.4.json",
    "11.5.2": "//cuda:redistrib/redistrib_11.5.2.json",
    "11.6.2": "//cuda:redistrib/redistrib_11.6.2.json",
    "11.7.1": "//cuda:redistrib/redistrib_11.7.1.json",
    "11.8.0": "//cuda:redistrib/redistrib_11.8.0.json",
    "12.0.0": "//cuda:redistrib/redistrib_12.0.0.json",
    "12.0.1": "//cuda:redistrib/redistrib_12.0.1.json",
    "12.1.0": "//cuda:redistrib/redistrib_12.1.0.json",
}

def register_cuda_toolchains(name = "remote_cuda_toolchain", version = "12.0.0", cuda_versions = CUDA_VERSIONS_JSON):
    _remote_cuda(name = name, json_path = cuda_versions[version])

    native.register_toolchains(
        "@local_cuda//toolchain:nvcc-local-toolchain",
        "@local_cuda//toolchain/clang:clang-local-toolchain",
        "@local_cuda//toolchain/disabled:disabled-local-toolchain",
    )

## buildifier: disable=unnamed-macro
#def register_detected_cuda_toolchains():
#    """Helper to register the automatically detected CUDA toolchain(s).
#
#User can setup their own toolchain if needed and ignore the detected ones by not calling this macro.
#"""
#    native.register_toolchains(
#        "@local_cuda//toolchain:nvcc-local-toolchain",
#        "@local_cuda//toolchain/clang:clang-local-toolchain",
#    )
