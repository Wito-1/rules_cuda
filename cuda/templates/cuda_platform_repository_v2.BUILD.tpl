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
        ":headers",
    ],
)

cc_library(
    name = "shared_stub_libs",
    deps = [
        "@cudnn-{{platform}}//:shared_stub_libs",
        ":headers",
    ],
)

cc_library(
    name = "static_libs",
    deps = [
        "@cudnn-{{platform}}//:static_libs",
        ":headers",
    ],
)

cc_library(
    name = "cudnn",
    deps = [
        ":shared_libs",
        ":shared_stub_libs",
        ":static_libs",
    ],
)
