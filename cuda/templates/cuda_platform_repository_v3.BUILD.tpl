load("@rules_cc//cc:defs.bzl", "cc_library")

package(
    default_visibility = ["//visibility:public"],
)

###############
# CUDA Runtime
###############
cc_library(
    name = "headers",
    deps = [
        "@cuda_cudart-{{platform}}//:headers",
        "@cuda_nvcc-{{platform}}//:headers",
    ],
)

cc_library(
    name = "cudart_shared_libs",
    deps = [
        "@cuda_cudart-{{platform}}//:shared_libs",
    ],
)

cc_library(
    name = "cudart_static_libs",
    deps = [
        "@cuda_cudart-{{platform}}//:static_libs",
    ],
)

cc_library(
    name = "cudart_shared_stub_libs",
    deps = [
        "@cuda_cudart-{{platform}}//:shared_stub_libs",
    ],
    linkopts = [
        "-ldl",
        "-lpthread",
        "-lrt",
    ],
)

cc_library(
    name = "cuda_runtime",
    deps = [
        ":headers",
        ":cudart_shared_libs",
        ":cudart_static_libs",
    ],
    linkopts = [
        "-ldl",
        "-lpthread",
        "-lrt",
    ],
    alwayslink = 1,
)

cc_library(
    name = "cuda_runtime_static",
    deps = [
        ":headers",
        ":cudart_static_libs",
    ],
    linkopts = [
        "-ldl",
        "-lpthread",
        "-lrt",
    ],
    alwayslink = 1,
)

cc_library(name = "no_cuda_runtime")

cc_library(
    name = "cuda",
    deps = [
        ":headers",
        ":cudart_shared_stub_libs",
    ],
)

###############
# cublas
###############
cc_library(
    name = "cublas",
    deps = [
        "@libcublas-{{platform}}//:shared_libs",
        ":cuda_runtime",
    ],
    linkopts = [
        "-ldl",
        "-lpthread",
        "-lrt",
    ],
)


###############
# CUPTI
###############
cc_library(
    name = "cupti",
    deps = [
        ":headers",
        "@cuda_cupti-{{platform}}//:shared_libs",
    ],
)

###############
# nvperf
###############
cc_library(
    name = "nvperf_host",
    deps = [
        ":headers",
        "@cuda_cupti-{{platform}}//:host_shared_libs",
    ],
)

cc_library(
    name = "nvperf_target",
    deps = [
        ":headers",
        "@cuda_cupti-{{platform}}//:target_shared_libs",
    ],
)

###############
# NVML
###############
cc_library(
    name = "nvml",
    deps = [
        ":headers",
        "@cuda_nvml_dev-{{platform}}//:shared_stub_libs",
    ],
)

###############
# curand
###############
cc_library(
    name = "curand",
    deps = [
        ":headers",
        "@libcurand-{{platform}}//:shared_libs",
    ],
)

###############
# cufft
###############
cc_library(
    name = "cufft",
    deps = [
        ":headers",
        "@libcufft-{{platform}}//:shared_libs",
    ],
)

###############
# cusolver
###############
cc_library(
    name = "cusolver",
    deps = [
        ":headers",
        "@libcusolver-{{platform}}//:shared_libs",
    ],
)

###############
# cusparse
###############
cc_library(
    name = "cusparse",
    deps = [
        ":headers",
        "@libcusparse-{{platform}}//:shared_libs",
    ],
)

###############
# nvtx
###############
cc_library(
    name = "nvtx",
    deps = [
        ":headers",
        "@cuda_nvtx-{{platform}}//:shared_libs",
    ],
)

###############
# nvrtc
###############
cc_library(
    name = "nvrtc",
    deps = [
        ":headers",
        "@cuda_nvrtc-{{platform}}//:shared_libs",
    ],
)

label_flag(
    name = "runtime",
    build_setting_default = ":cuda_runtime",
)
