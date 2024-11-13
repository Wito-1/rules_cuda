package(
    default_visibility = ["//visibility:public"],
)

cc_library(
    name = "headers",
    hdrs = [":includes"],
    includes = ["include"],
)

filegroup(
    name = "includes",
    srcs = glob(["**/*.hpp", "**/*.h"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "nvvm",
    srcs = glob(
       ["nvvm/**"],
       exclude = ["nvvm/libnvvm-samples"],
       allow_empty = True,
    ),
    visibility = ["//visibility:public"],
)

exports_files(glob(["**/*"]))
