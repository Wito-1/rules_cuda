load("@rules_cc//cc:defs.bzl", "cc_library")

package(
    default_visibility = ["//visibility:public"],
)

exports_files(glob(["**/*"]))

cc_library(
    name = "hdrs",
    hdrs = glob(["**/*.hpp", "**/*.h"], allow_empty=True),
    includes = ["include"],
)

cc_library(
    name = "static_libs",
    srcs = glob(["lib/*.a"], allow_empty=True),
    deps = [":hdrs"],
)

cc_library(
    name = "shared_libs",
    srcs = glob(["lib/*.so*"], allow_empty=True),
    deps = [":hdrs"],
)

cc_library(
    name = "shared_stub_libs",
    srcs = glob(["lib/stubs/*.so*"], allow_empty=True),
    deps = [":hdrs"],
)
