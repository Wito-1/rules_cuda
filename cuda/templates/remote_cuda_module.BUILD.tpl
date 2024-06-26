package(
    default_visibility = ["//visibility:public"],
)

cc_library(
    name = "hdrs",
    hdrs = glob(["**/*.hpp", "**/*.h"]),
    includes = ["include"],
)

exports_files(glob(["**/*"]))

filegroup(
    name = "includes",
    srcs = glob(["**/*.hpp", "**/*.h"], allow_empty=True),
    visibility = ["//visibility:public"],
)
