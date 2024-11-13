# This becomes the BUILD file for @local_cuda//toolchain/ under Linux.

load(
    "@rules_cuda//cuda:defs.bzl",
    "cuda_toolchain",
    "cuda_toolkit",
    cuda_toolchain_config = "cuda_toolchain_config_nvcc",
)

cuda_toolkit(
    name = "cuda-toolkit",
    bin2c = "@{{repo}}//cuda_nvcc:bin/bin2c",
    fatbinary = "@{{repo}}//cuda_nvcc:bin/bin2c",
    link_stub = "@{{repo}}//cuda_nvcc:bin/crt/link.stub",
    nvlink = "@{{repo}}//cuda_nvcc:bin/nvlink",
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
        "@{{repo}}//cuda_cudart:includes",
        "@{{repo}}//cuda_nvcc:bin/bin2c",
        "@{{repo}}//cuda_nvcc:bin/crt/link.stub",
        "@{{repo}}//cuda_nvcc:bin/nvcc",
        "@{{repo}}//cuda_nvcc:bin/nvcc.profile",
        "@{{repo}}//cuda_nvcc:bin/nvlink",
        "@{{repo}}//cuda_nvcc:bin/ptxas",
        "@{{repo}}//cuda_nvcc:bin/fatbinary",
        "@{{repo}}//cuda_nvcc:bin/cudafe++",
        "@{{repo}}//cuda_nvcc:includes",
        "@{{repo}}//cuda_nvcc:nvvm",
    ],
)

cuda_toolchain(
    name = "nvcc",
    compiler_executable = "external/_{repo}~/cuda_nvcc/bin/nvcc",
    compiler_files = ":nvcc-compiler-files",
    toolchain_config = ":nvcc-config",
)

toolchain(
    name = "nvcc-toolchain",
    exec_compatible_with = [
        "@platforms//os:{{os}}",
        "@platforms//arch:{{arch}}",
    ],
    target_compatible_with = [
        "@platforms//os:{{os}}",
        "@platforms//arch:{{arch}}",
    ],
    toolchain = ":nvcc",
    toolchain_type = "@rules_cuda//cuda:toolchain_type",
    visibility = ["//visibility:public"],
)
