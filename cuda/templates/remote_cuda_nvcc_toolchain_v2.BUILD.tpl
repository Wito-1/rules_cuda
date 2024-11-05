# This becomes the BUILD file for @cuda//toolchain/ under Linux.

load(
    "@rules_cuda//cuda:defs.bzl",
    "cuda_toolchain",
    "cuda_toolkit",
    cuda_toolchain_config = "cuda_toolchain_config_nvcc",
)

cuda_toolkit(
    name = "cuda-toolkit-{{platform}}",
    bin2c = "@@{{repo}}//:bin/bin2c",
    fatbinary = "@@{{repo}}//:bin/bin2c",
    link_stub = "@@{{repo}}//:bin/crt/link.stub",
    nvlink = "@@{{repo}}//:bin/nvlink",
    path = "/doesNotExist",
    version = "{{major}}.{{minor}}",
)

cuda_toolchain_config(
    name = "nvcc-config-{{platform}}",
    cuda_toolkit = ":cuda-toolkit-{{platform}}",
    nvcc_version_major = {{major}},
    nvcc_version_minor = {{minor}},
    toolchain_identifier = "nvcc",
)

filegroup(
    name = "nvcc-compiler-files-{{platform}}",
    srcs = [
        "@@{{repo}}//:bin/bin2c",
        "@@{{repo}}//:bin/crt/link.stub",
        "@@{{repo}}//:bin/nvcc",
        "@@{{repo}}//:bin/nvcc.profile",
        "@@{{repo}}//:bin/nvlink",
        "@@{{repo}}//:bin/ptxas",
        "@@{{repo}}//:bin/fatbinary",
        "@@{{repo}}//:bin/cudafe++",
        "@@{{repo}}//:includes",
        "@@{{repo}}//:nvvm",
    ],
)

cuda_toolchain(
    name = "nvcc-{{platform}}",
    compiler_executable = "external/{{repo}}/bin/nvcc",
    compiler_files = ":nvcc-compiler-files-{{platform}}",
    toolchain_config = ":nvcc-config-{{platform}}",
)

toolchain(
    name = "nvcc-toolchain-{{platform}}",
    exec_compatible_with = ["@platforms//cpu:{{exec_arch}}", "@platforms//os:{{exec_os}}"],
    target_compatible_with = ["@platforms//cpu:{{target_arch}}", "@platforms//os:{{target_os}}"],
    toolchain = ":nvcc-{{platform}}",
    toolchain_type = "@rules_cuda//cuda:toolchain_type",
    visibility = ["//visibility:public"],
)
