package(
    default_visibility = ["//visibility:public"],
)

cc_library(
    name = "hdrs",
    hdrs = glob(["**/*.hpp", "**/*.h"], allow_empty=True),
    includes = ["include"],
)

exports_files(glob(["**/*"]))

filegroup(
    name = "{{MODULE_NAME}}_so",
    srcs = glob(["lib/*.so*"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "{{MODULE_NAME}}_stubs_so",
    srcs = glob(["lib/stubs/*.so*"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "includes",
    srcs = glob(["**/*.hpp", "**/*.h"], allow_empty=True),
    visibility = ["//visibility:public"],
)
