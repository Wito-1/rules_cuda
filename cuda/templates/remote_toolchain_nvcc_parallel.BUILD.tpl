# This becomes the BUILD file for @local_cuda//toolchain/ under Linux.

load(
    "@rules_cuda//cuda:defs.bzl",
    "cuda_toolchain",
    "cuda_toolkit",
    cuda_toolchain_config = "cuda_toolchain_config_nvcc",
)

cuda_toolkit(
    name = "cuda-toolkit",
    bin2c = "@cuda_nvcc-{{platform}}//:bin/bin2c",
    fatbinary = "@cuda_nvcc-{{platform}}//:bin/bin2c",
    link_stub = "@cuda_nvcc-{{platform}}//:bin/crt/link.stub",
    nvlink = "@cuda_nvcc-{{platform}}//:bin/nvlink",
    path = "/doesNotExist",
    version = "{{major}}.{{minor}}",
)

cuda_toolchain_config(
    name = "nvcc-config",
    cuda_toolkit = ":cuda-toolkit",
    nvcc_version_major = {{major}},
    nvcc_version_minor = {{minor}},
    toolchain_identifier = "nvcc",
)

filegroup(
    name = "nvcc-compiler-files",
    srcs = [
        "@cuda_cudart-{{platform}}//:hdrs",
        "@cuda_nvcc-{{platform}}//:bin/bin2c",
        "@cuda_nvcc-{{platform}}//:bin/crt/link.stub",
        "@cuda_nvcc-{{platform}}//:bin/nvcc",
        "@cuda_nvcc-{{platform}}//:bin/nvcc.profile",
        "@cuda_nvcc-{{platform}}//:bin/nvlink",
        "@cuda_nvcc-{{platform}}//:bin/ptxas",
        "@cuda_nvcc-{{platform}}//:bin/fatbinary",
        "@cuda_nvcc-{{platform}}//:bin/cudafe++",
        "@cuda_nvcc-{{platform}}//:hdrs",
        "@cuda_nvcc-{{platform}}//:nvvm",
    ],
)

cuda_toolchain(
    name = "nvcc",
    compiler_executable = "external/rules_cuda~~toolchain_parallel~cuda_nvcc-{{platform}}/bin/nvcc",
    compiler_files = ":nvcc-compiler-files",
    toolchain_config = ":nvcc-config",
)

toolchain(
    name = "nvcc-toolchain",
    exec_compatible_with = [
        "@platforms//os:{{os}}",
        "@platforms//cpu:{{arch}}",
    ],
    target_compatible_with = [
        "@platforms//os:{{os}}",
        "@platforms//cpu:{{arch}}",
    ],
    toolchain = ":nvcc",
    toolchain_type = "@rules_cuda//cuda:toolchain_type",
    visibility = ["//visibility:public"],
)
