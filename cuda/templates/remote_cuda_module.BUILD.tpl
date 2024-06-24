package(
    default_visibility = ["//visibility:public"],
)

cc_library(
    name = "hdrs",
    hdrs = glob(["**/*.hpp", "**/*.h", "**/*.hh"]),
    includes = ["include"],
)

exports_files(glob(["**/*"]))
