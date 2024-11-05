load("@rules_cc//cc:defs.bzl", "cc_library")

package(
    default_visibility = ["//visibility:public"],
)

cc_library(
    name = "headers",
    deps = [
        "@cudnn-{{platform}}//:hdrs",
    ],
)

cc_library(
    name = "shared_libs",
    deps = [
        "@cudnn-{{platform}}//:shared_libs",
    ],
)

cc_library(
    name = "shared_stub_libs",
    deps = [
        "@cudnn-{{platform}}//:shared_stub_libs",
    ],
)

cc_library(
    name = "static_libs",
    deps = [
        "@cudnn-{{platform}}//:static_libs",
    ],
)
