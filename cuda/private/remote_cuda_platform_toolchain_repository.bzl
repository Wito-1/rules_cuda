"""
Creates a repository for a cuda platform toolchain definition
"""
def _cuda_platform_toolchain_impl(rctx):
    # Output the toolchain definitions
    print(rctx.attr.nvcc_repository)
    print(Label(rctx.attr.nvcc_repository).name)
    print(Label(rctx.attr.nvcc_repository).repo_name)

    rctx.template(
        "BUILD.bazel",
        rctx.attr.cuda_nvcc_toolchain_build_file_template,
        substitutions = {
            "{{arch}}": rctx.attr.arch,
            "{{platform}}": rctx.attr.platform,
            "{{repo}}": Label(rctx.attr.nvcc_repository).repo_name,
            "{{major}}": rctx.attr.major,
            "{{minor}}": rctx.attr.minor,
            "{{os}}": rctx.attr.os,
        },
    )

cuda_platform_toolchain = repository_rule(
    implementation = _cuda_platform_toolchain_impl,
    attrs = {
        "arch": attr.string(
            mandatory = True,
            doc = "Architecure for toolchain",
        ),
        "platform": attr.string(
            mandatory = True,
            doc = "Platform",
        ),
        "major": attr.string(
            mandatory = True,
            doc = "Major version",
        ),
        "minor": attr.string(
            mandatory = True,
            doc = "Minor version",
        ),
        "os": attr.string(
            mandatory = True,
            doc = "OS version",
        ),
        "nvcc_repository": attr.label(
            doc = "nvcc repository",
            mandatory = True,
#            default = "@cuda_nvcc-linux-x86_64-remote_cuda",
        ),
        "cuda_nvcc_toolchain_build_file_template": attr.label(
            allow_single_file = True,
            default = Label("//cuda:templates/remote_cuda_nvcc_toolchain.BUILD.tpl"),
        ),
    },
)
