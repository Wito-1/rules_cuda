"""
Create a BUILD.bazel file with select() statements for each platform provided
"""

ALIAS_TEMPLATE = """
package(
    default_visibility = ["//visibility:public"],
)

TARGETS = [{{BZL_TARGETS}}]

[alias(
    name = "{}".format(tgt),
    actual = select({
        "{{PLATFORM_CONSTRAINT}}": "@@{{PLATFORM_REPO}}//:{}".format(tgt),
    }),
) for tgt in TARGETS]
"""


def _cuda_cross_platform_alias_impl(rctx):
    out_lines = []
    for line in ALIAS_TEMPLATE.split("\n"):
        # Expand to list a select from each platform input
        if "{{BZL_TARGETS}}" in line:
            line = line.replace("{{BZL_TARGETS}}", ",".join(["\"{}\"".format(lib) for lib in rctx.attr.cuda_libraries]))

        if "{{PLATFORM_CONSTRAINT}}" in line:
            for label, platform in rctx.attr.cuda_platform_repositories.items():
                platform_line = line.replace("{{PLATFORM_REPO}}", "{}".format(label.repo_name))
                out_lines.append(platform_line.replace("{{PLATFORM_CONSTRAINT}}", "@rules_cuda//cuda:{platform}.constraint".format(platform=platform)))

            continue

        out_lines.append(line)
    rctx.file("BUILD.bazel", content = "\n".join(out_lines))

    # Create some convenience toplevel loadables in cuda/defs.bzl
    rctx.file("cuda/BUILD.bazel", content = "")
    rctx.symlink(rctx.attr.cuda_rule_wrappers, "cuda/defs.bzl")

cuda_cross_platform_alias = repository_rule(
    implementation = _cuda_cross_platform_alias_impl,
    attrs = {
        #"cuda_platform_repositories": attr.string_dict(
        "cuda_platform_repositories": attr.label_keyed_string_dict(
            doc = "List of platforms to create alias cuda rules for", 
            mandatory = True,
        ),
        "cuda_cross_platform_alias_template": attr.label(
            allow_single_file=True,
            default = Label("//cuda:templates/remote_cuda_cross_platform_toplevel.BUILD.tpl"),
        ),
        "cuda_rule_wrappers": attr.label(
            allow_single_file=True,
            default = Label("//cuda:templates/defs.bzl.tpl"),
        ),
        "cuda_libraries": attr.string_list(
            default = [
                "headers",
                "cudart_shared_libs",
                "cudart_static_libs",
                "cudart_shared_stub_libs",
                "cuda_runtime",
                "cuda_runtime_static",
                "no_cuda_runtime",
                "cuda",
                "cublas",
                "cupti",
                "nvperf_host",
                "nvperf_target",
                "nvml",
                "curand",
                "cufft",
                "cusolver",
                "cusparse",
                "nvtx",
                "nvrtc",
                "runtime",
#                "cuda_nvtx",
            ],
        ),
    },
)
