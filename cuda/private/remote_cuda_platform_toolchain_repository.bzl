"""
Creates a repository for all cuda platforms' toolchain definitions
"""
load("//cuda/private:utils.bzl", "get_os_arch", "get_versions", "get_platform_args_dict")

def _get_toolchain_spec(rctx, exec_platform, target_platform, template, cross_compile=False):
    exec_os, exec_arch = get_os_arch(exec_platform)
    target_os, target_arch = get_os_arch(target_platform)
    major, minor = get_versions(rctx.attr.version[exec_platform])

    arch_build_file_contents = template

    target_platforms = ["\"@platforms//os:{}\"".format(target_os), "\"@platforms//cpu:{}\"".format(target_arch)]

    repo = Label(rctx.attr.nvcc_repository[exec_platform]).repo_name
    platform = exec_platform if cross_compile == False else "cross-{}".format(target_platform)

    substitutions = {
        "{{exec_os}}": exec_os,
        "{{exec_arch}}": exec_arch,
        "{{target_os}}": target_os,
        "{{target_arch}}": target_arch,
        "{{platform}}": platform,
        "{{repo}}": repo,
        "{{major}}": major,
        "{{minor}}": minor,
    }

    for sub, value in substitutions.items():
        arch_build_file_contents = arch_build_file_contents.replace(sub, value)

    return arch_build_file_contents

def _cuda_platform_toolchains_impl(rctx):

    template = rctx.read(rctx.attr.cuda_nvcc_toolchain_build_file_template)
    arch_specific_defs = []
    for platform in rctx.attr.nvcc_repository:
        arch_specific_defs += [_get_toolchain_spec(rctx, platform, platform, template)]
        # Add any cross-compilation toolchain definitions
        for cross_platform in rctx.attr.nvcc_repository:
            if cross_platform != platform:
                arch_specific_defs += [_get_toolchain_spec(rctx, platform, cross_platform, template, cross_compile=True)]

    rctx.file("BUILD.bazel", content = "\n".join(arch_specific_defs))


cuda_platform_toolchains = repository_rule(
    implementation = _cuda_platform_toolchains_impl,
    attrs = {
        "version": attr.string_dict(
            mandatory = True,
            doc = "Version of the nvcc, where the keys are the platforms (eg. {\"linux-x86_64\": \"11.8.5\"})",
        ),
        "nvcc_repository": attr.string_keyed_label_dict(
            doc = "nvcc repository dictionary, where the keys are the platforms (eg. {\"linux-x86_64\": \"@cuda_nvcc-linux-x86_64-cuda\"}",
            mandatory = True,
        ),
        "cuda_nvcc_toolchain_build_file_template": attr.label(
            allow_single_file = True,
            default = Label("//cuda:templates/remote_cuda_nvcc_toolchain_v2.BUILD.tpl"),
        ),
    },
)
