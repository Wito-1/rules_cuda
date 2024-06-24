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
    version = "{{major_version}}.{{minor_version}}",
)

cuda_toolchain_config(
    name = "nvcc-local-config",
    cuda_toolkit = ":cuda-toolkit",
    nvcc_version_major = {{major_version}},
    nvcc_version_minor = {{minor_version}},
    toolchain_identifier = "nvcc",
)

filegroup(
    name = "nvcc-compiler-files",
    srcs = [
        "@cuda_cudart-{{platform}}//:includes",
        "@cuda_nvcc-{{platform}}//:bin/bin2c",
        "@cuda_nvcc-{{platform}}//:bin/crt/link.stub",
        "@cuda_nvcc-{{platform}}//:bin/nvcc",
        "@cuda_nvcc-{{platform}}//:bin/nvcc.profile",
        "@cuda_nvcc-{{platform}}//:bin/nvlink",
        "@cuda_nvcc-{{platform}}//:bin/ptxas",
        "@cuda_nvcc-{{platform}}//:bin/fatbinary",
        "@cuda_nvcc-{{platform}}//:bin/cudafe++",
        "@cuda_nvcc-{{platform}}//:includes",
        "@cuda_nvcc-{{platform}}//:nvvm",
    ],
)

cuda_toolchain(
    name = "nvcc-local",
    compiler_executable = "external/cuda_nvcc-{{platform}}/bin/nvcc",
    compiler_files = ":nvcc-compiler-files",
    toolchain_config = ":nvcc-local-config",
)

toolchain(
    name = "nvcc-local-toolchain",
    exec_compatible_with = [
        "@platforms//os:{{os}}",
    ],
    target_compatible_with = [
        "@platforms//os:{{os}}",
        "@platforms//arch:{{arch}}",
    ],
    toolchain = ":nvcc-local",
    toolchain_type = "@rules_cuda//cuda:toolchain_type",
    visibility = ["//visibility:public"],
)
