package(
    default_visibility = ["//visibility:public"],
)

cc_library(
    name = "hdrs",
    hdrs = glob(["**/*.hpp", "**/*.h", "**/*.hh"]),
    includes = ["include"],
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

#filegroup(
#    name = "includes",
#    srcs = glob(
#        ["include/**", "nvvm/include/**"],
#        allow_empty = True,
#    ),
#    visibility = ["//visibility:public"],
#)

exports_files(glob(["**/*"]))
