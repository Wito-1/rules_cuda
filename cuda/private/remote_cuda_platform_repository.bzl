def _cuda_platform_impl(rctx):
    # Output a toplevel BUILD.bazel file
    rctx.template(
        "BUILD.bazel",
        rctx.attr.cuda_platform_build_file_template,
        substitutions = {
            "{{platform}}": rctx.attr.platform,
        },
    )

cuda_platform = repository_rule(
    implementation = _cuda_platform_impl,
    attrs = {
        "platform": attr.string(mandatory = True),
        "cuda_platform_build_file_template": attr.label(
            allow_single_file = True,
            default = Label("//cuda:templates/cuda_platform_repository.BUILD.tpl"),
        ),
    },
)
