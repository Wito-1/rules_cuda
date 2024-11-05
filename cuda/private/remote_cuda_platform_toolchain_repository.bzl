"""
Creates a repository for all cuda platforms' toolchain definitions
"""
load("//cuda/private:utils.bzl", "get_os_arch", "get_versions", "get_platform_args_dict")

def _cuda_platform_toolchains_impl(rctx):

    template = rctx.read(rctx.attr.cuda_nvcc_toolchain_build_file_template)
    arch_specific_defs = []
    for platform in rctx.attr.nvcc_repository:
        os, arch = get_os_arch(platform)
        major, minor = get_versions(rctx.attr.version[platform])

        arch_build_file_contents = template

        substitutions = {
            "{{arch}}": arch,
            "{{platform}}": platform,
            "{{repo}}": Label(rctx.attr.nvcc_repository[platform]).repo_name,
            "{{major}}": major,
            "{{minor}}": minor,
            "{{os}}": os,
        }

        for sub, value in substitutions.items():
            arch_build_file_contents = arch_build_file_contents.replace(sub, value)

        arch_specific_defs += [arch_build_file_contents]

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
