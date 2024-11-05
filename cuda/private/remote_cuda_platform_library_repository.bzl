"""
Creates a repository for a specific cuda library in a redistributable
"""
def _cuda_platform_library_impl(rctx):
    rctx.download_and_extract(
        url = rctx.attr.url,
        sha256 = rctx.attr.sha256,
        stripPrefix = rctx.attr.strip_prefix,
    )

    if rctx.attr.build_file == None:
        if "nvcc" in rctx.attr.repo_name:
            rctx.symlink(rctx.attr.nvcc_library_build_file, "BUILD.bazel")
        else:
            rctx.template(
                "BUILD.bazel",
                rctx.attr.cuda_library_build_file_template,
                substitutions = {
                    "{{MODULE_NAME}}": rctx.attr.repo_name,
                }
            )
    else:
        rctx.symlink(Label(rctx.attr.build_file), "BUILD.bazel")


cuda_platform_library = repository_rule(
    implementation = _cuda_platform_library_impl,
    attrs = {
        "repo_name": attr.string(mandatory = True),
        "sha256": attr.string(mandatory = True),
        "url": attr.string(mandatory = True),
        "strip_prefix": attr.string(default = ""),
        "build_file": attr.label(allow_single_file = True),
        "nvcc_library_build_file": attr.label(
            allow_single_file = True,
            default = Label("//cuda:templates/nvcc_cuda_platform_library.BUILD.tpl"),
        ),
        "cuda_library_build_file_template": attr.label(
            allow_single_file = True,
            default = Label("//cuda:templates/cuda_platform_library.BUILD.tpl"), 
        ),
    },
)
