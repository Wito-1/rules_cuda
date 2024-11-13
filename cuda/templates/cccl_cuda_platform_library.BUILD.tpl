load("@rules_cc//cc:defs.bzl", "cc_library")

package(
    default_visibility = ["//visibility:public"],
)

exports_files(glob(["**/*"]))

cc_library(
    name = "headers",
    deps = [
        ":cuda_headers",
        ":nv_headers",
        ":cub_headers",
        ":thrust_headers",
    ],
)

cc_library(
    name = "cuda_headers",
    hdrs = glob(["include/cuda/**"], allow_empty=True),
    includes = ["include"],
)

cc_library(
    name = "nv_headers",
    hdrs = glob(["include/nv/**"], allow_empty=True),
    includes = ["include"],
)

cc_library(
    name = "cub_headers",
    hdrs = glob(["include/cub/**"], allow_empty=True),
    includes = ["include"],
)

cc_library(
    name = "thrust_headers",
    hdrs = glob(["include/thrust/**"], allow_empty=True),
    includes = ["include"],
)
