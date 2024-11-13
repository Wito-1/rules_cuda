load("@rules_cc//cc:defs.bzl", "cc_library")
#load("@rules_license//rules:license.bzl", "license")

#package(default_applicable_licenses = [":license"])

#license(
#    name = "license",
#    license_kinds = [
#        "@rules_license//licenses/spdx:BSD-3-Clause",
#    ],
#    license_text = "LICENSE.TXT",
#)

cc_library(
    name = "includes",
    includes = [".", "cub"],
    textual_hdrs = glob([
        "cub/*.cuh",
        "cub/agent/*.cuh",
        "cub/block/*.cuh",
        "cub/block/specializations/*.cuh",
        "cub/device/*.cuh",
        "cub/device/dispatch/*.cuh",
        "cub/grid/*.cuh",
        "cub/host/*.cuh",
        "cub/warp/*.cuh",
        "cub/warp/specializations/*.cuh",
        "cub/iterator/*.cuh",
        "cub/thread/*.cuh",
        "cub/detail/*.cuh",
    ], allow_empty = True),
)

cc_library(
    name = "cub",
    visibility = ["//visibility:public"],
    deps = [":includes"],
)
