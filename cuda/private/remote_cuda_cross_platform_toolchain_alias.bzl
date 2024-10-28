"""
Create a repo containing aliases to all nvcc toolchains so they can easily be registered
"""

def _cuda_cross_platform_toolchain_alias_impl(rctx):
    # Reads in the template file
    aliases = []

    for label, platform in rctx.attr.cuda_platform_repositories.items():
        aliases.append("""
alias(
    name = "nvcc-toolchain-{PLATFORM}",
    actual = "{PLATFORM_REPO}//toolchain:nvcc-toolchain-{PLATFORM}"
)
""".format(PLATFORM=platform, PLATFORM_REPO=label.repo_name))

    build_file_content = """
package(
    default_visibility = ["//visibility:public"],
)
"""

    build_file_content += "\n".join(aliases)

    rctx.file("BUILD.bazel", content = build_file_content)

cuda_cross_platform_toolchain_alias = repository_rule(
    implementation = _cuda_cross_platform_toolchain_alias_impl,
    attrs = {
        "cuda_platform_repositories": attr.label_keyed_string_dict(
            doc = "List of platforms to create alias cuda rules for", 
            mandatory = True,
        ),
    },
)
