package(
    default_visibility = ["//visibility:public"],
)

cc_library(
    name = "cuda_headers",
    deps = [
        "@cuda_cudart-{{platform}}//:hdrs",
        "@cuda_nvcc-{{platform}}//:hdrs",
    ],
)

cc_library(
    name = "cuda_stub",
    srcs = ["@cuda_cudart-{{platform}}//:lib/stubs/libcuda.so"],
    linkopts = [
        "-ldl",
        "-lpthread",
        "-lrt",
    ],
)

cc_library(
    name = "cudart_so",
    srcs = ["@cuda_cudart-{{platform}}//:cuda_cudart_so"],
    target_compatible_with = ["@platforms//os:linux"],
    alwayslink = 1,
)

cc_library(
    name = "cudadevrt_a",
    srcs = ["@cuda_cudart-{{platform}}//:lib/libcudadevrt.a"],
    target_compatible_with = ["@platforms//os:linux"],
    alwayslink = 1,
)

# Note: do not use this target directly, use the configurable label_flag
# @rules_cuda//cuda:runtime instead.
cc_library(
    name = "cuda_runtime",
    linkopts = [
        "-ldl",
        "-lpthread",
        "-lrt",
    ],
    alwayslink = 1,
    deps = [
        "@cuda_cudart-{{platform}}//:hdrs",
        "@cuda_nvcc-{{platform}}//:hdrs",
    ] + [
        # devrt is require for jit linking when rdc is enabled
        ":cudadevrt_a",
        ":cudart_so",
    ],
)

# Note: do not use this target directly, use the configurable label_flag
# @rules_cuda//cuda:runtime instead.
cc_library(
    name = "cuda_runtime_static",
    srcs = ["@cuda_cudart-{{platform}}//:lib/libcudart_static.a"],
    linkopts = [
        "-ldl",
        "-lpthread",
        "-lrt",
    ],
    deps = [":cuda_headers", ":cudadevrt_a"],
)

cc_library(
    name = "no_cuda_runtime",
)

cc_library(
    name = "cuda_so",
    srcs = [
        "@cuda_cudart-{{platform}}//:cuda_cudart_stubs_so"
    ],
    linkopts = [
        "-ldl",
        "-lpthread",
        "-lrt",
    ],
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "cuda",
    deps = [
        ":cuda_headers",
        ":cuda_so",
    ],
)

cc_library(
    name = "cublas_so",
    srcs = ["@libcublas-{{platform}}//:libcublas_so"],
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "cublas",
    deps = [
        ":cublas_so",
        ":cuda_runtime",
        "@libcublas-{{platform}}//:hdrs",
    ],
)

# CUPTI
cc_library(
    name = "cupti_so",
    srcs = ["@cuda_cupti-{{platform}}//:cuda_cupti_so"],
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "cupti",
    deps = [
        ":cuda_headers",
        ":cupti_so",
    ],
)

# nvperf
cc_import(
    name = "nvperf_host_so",
    shared_library = "@cuda_cupti-{{platform}}//:lib/libnvperf_host.so",
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "nvperf_host",
    deps = [
        ":cuda_headers",
    ] + [
        ":nvperf_host_so",
    ],
)

cc_import(
    name = "nvperf_target_so",
    shared_library = "@cuda_cupti-{{platform}}//:lib/libnvperf_target.so",
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "nvperf_target",
    deps = [
        ":cuda_headers",
    ] + [
        ":nvperf_target_so",
    ],
)

# NVML
cc_import(
    name = "nvidia-ml_so",
    shared_library = "@cuda_nvml_dev-{{platform}}//:lib/stubs/libnvidia-ml.so",
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "nvml",
    deps = [
        ":cuda_headers",
        "@cuda_nvml_dev-{{platform}}//:hdrs",
    ] + [
        ":nvidia-ml_so",
    ],
)

# curand
cc_library(
    name = "curand_so",
    srcs = ["@libcurand-{{platform}}//:libcurand_so"],
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "curand",
    deps = [
        ":cuda_headers",
    ] + [
        ":curand_so",
    ],
)

# nvptxcompiler
cc_import(
    name = "nvptxcompiler_so",
    static_library = "@cuda_nvcc-{{platform}}//:lib/libnvptxcompiler_static.a",
    target_compatible_with = ["@platforms//os:linux"],
)

# cufft
cc_library(
    name = "cufft_so",
    srcs = ["@libcufft-{{platform}}//:libcufft_so"],
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "cufft",
    deps = [
        ":cuda_headers",
        ":cufft_so",
    ],
)

# cusolver
cc_library(
    name = "cusolver_so",
    srcs = ["@libcusolver-{{platform}}//:libcusolver_so"],
    target_compatible_with = ["@platforms//os:linux"],
)


cc_library(
    name = "cusolver",
    deps = [
        ":cuda_headers",
        ":cusolver_so",
    ],
)

# cusparse
cc_library(
    name = "cusparse_so",
    srcs = ["@libcusparse-{{platform}}//:libcusparse_so"],
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "cusparse",
    deps = [
        ":cuda_headers",
        ":cusparse_so",
    ],
)

# nvtx
cc_library(
    name = "cuda_nvtx_so",
    srcs = ["@cuda_nvtx-{{platform}}//:cuda_nvtx_so"],
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "cuda_nvtx",
    deps = [
        ":cuda_headers",
        ":cuda_nvtx_so",
    ],
)

label_flag(
    name = "runtime",
    build_setting_default = ":cuda_runtime",
)
