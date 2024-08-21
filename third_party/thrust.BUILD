load("@rules_cc//cc:defs.bzl", "cc_library")
#load("@rules_license//rules:license.bzl", "license")

#package(default_applicable_licenses = [":license"])

#license(
#    name = "license",
#    license_kinds = [
#        "@rules_license//licenses/spdx:Apache-2.0",
#        "@rules_license//licenses/spdx:BSL-1.0",
#    ],
#    license_text = "LICENSE",
#)

filegroup(
    name = "include-src",
    srcs = glob([
        "thrust/*.h",
        "thrust/**/*.h",
        "thrust/**/*.inl",
    ]),
)

cc_library(
    name = "includes",
    hdrs = [":include-src"],
    includes = ["."],
)

cc_library(
    name = "thrust",
    visibility = ["//visibility:public"],
    deps = [
        ":includes",
        "@cub",
    ],
)
