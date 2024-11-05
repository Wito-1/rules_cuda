package(
    default_visibility = ["//visibility:public"],
)

cc_library(
    name = "cuda_headers",
    deps = select({
        "{{PLATFORM_CONSTRAINT}}": ["@cuda_cudart-{{PLATFORM}}//:hdrs", "@cuda_nvcc-{{PLATFORM}}//:hdrs"],
        "//conditions:default": ["@cuda_cudart-{{host_platform}}//:hdrs", "@cuda_nvcc-{{host_platform}}//:hdrs"],
    }),
)

cc_library(
    name = "cuda_stub",
    srcs = select({
        "{{PLATFORM_CONSTRAINT}}": ["@cuda_cudart-{{PLATFORM}}//:lib/stubs/libcuda.so"],
        "//conditions:default": ["@cuda_cudart-{{host_platform}}//:lib/stubs/libcuda.so"],
    }),
    linkopts = [
        "-ldl",
        "-lpthread",
        "-lrt",
    ],
)

cc_library(
    name = "cudart_so",
    srcs = select({
        "{{PLATFORM_CONSTRAINT}}": ["@cuda_cudart-{{PLATFORM}}//:lib/libcudart.so"],
        "//conditions:default": ["@cuda_cudart-{{host_platform}}//:lib/libcudart.so"],
    }),
    target_compatible_with = ["@platforms//os:linux"],
    alwayslink = 1,
)

cc_library(
    name = "cudadevrt_a",
    srcs = select({
        "{{PLATFORM_CONSTRAINT}}": ["@cuda_cudart-{{PLATFORM}}//:lib/libcudadevrt.a"],
        "//conditions:default": ["@cuda_cudart-{{host_platform}}//:lib/libcudadevrt.a"],
    }),
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
    deps = select({
        "{{PLATFORM_CONSTRAINT}}": ["@cuda_cudart-{{PLATFORM}}//:hdrs", "@cuda_nvcc-{{PLATFORM}}//:hdrs"],
        "//conditions:default": ["@cuda_cudart-{{host_platform}}//:hdrs", "@cuda_nvcc-{{host_platform}}//:hdrs"],
    }) + [
        # devrt is require for jit linking when rdc is enabled
        ":cudadevrt_a",
        ":cudart_so",
    ],
)

# Note: do not use this target directly, use the configurable label_flag
# @rules_cuda//cuda:runtime instead.
cc_library(
    name = "cuda_runtime_static",
    srcs = select({
        "{{PLATFORM_CONSTRAINT}}": ["@cuda_cudart-{{PLATFORM}}//:lib/libcudart_static.a"],
        "//conditions:default": ["@cuda_cudart-{{host_platform}}//:lib/libcudart_static.a"],
    }),
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

cc_import(
    name = "cuda_so",
    shared_library = select({
        "{{PLATFORM_CONSTRAINT}}": "@cuda_cudart-{{PLATFORM}}//:lib/stubs/libcuda.so", 
        "//conditions:default": "@cuda_cudart-{{host_platform}}//:lib/stubs/libcuda.so",
    }),
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "cuda",
    deps = [
        ":cuda_headers",
    ] + [
        ":cuda_so",
    ],
)

cc_import(
    name = "cublas_so",
    shared_library = select({
        "{{PLATFORM_CONSTRAINT}}": "@libcublas-{{PLATFORM}}//:lib/libcublas.so",
        "//conditions:default": "@libcublas-{{host_platform}}//:lib/libcublas.so",
    }),
    target_compatible_with = ["@platforms//os:linux"],
)

cc_import(
    name = "cublasLt_so",
    shared_library = select({
        "{{PLATFORM_CONSTRAINT}}": "@libcublas-{{PLATFORM}}//:lib/libcublasLt.so",
        "//conditions:default": "@libcublas-{{host_platform}}//:lib/libcublasLt.so",
    }),
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "cublas",
    deps = [":cuda_runtime"] + select({
        "{{PLATFORM_CONSTRAINT}}": ["@libcublas-{{PLATFORM}}//:hdrs"],
        "//conditions:default": ["@libcublas-{{host_platform}}//:hdrs"],
    }) + [
        ":cublasLt_so",
        ":cublas_so",
    ],
)

# CUPTI
cc_import(
    name = "cupti_so",
    shared_library = select({
        "{{PLATFORM_CONSTRAINT}}": "@cuda_cupti-{{PLATFORM}}//:lib/libcupti.so",
        "//conditions:default": "@cuda_cupti-{{host_platform}}//:lib/libcupti.so",
    }),
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "cupti",
    deps = [
        ":cuda_headers",
    ] + [
        ":cupti_so",
    ],
)

# nvperf
cc_import(
    name = "nvperf_host_so",
    shared_library = select({
        "{{PLATFORM_CONSTRAINT}}": "@cuda_cupti-{{PLATFORM}}//:lib/libnvperf_host.so",
        "//conditions:default": "@cuda_cupti-{{host_platform}}//:lib/libnvperf_host.so",
    }),
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
    shared_library = select({
        "{{PLATFORM_CONSTRAINT}}": "@cuda_cupti-{{PLATFORM}}//:lib/libnvperf_target.so",
        "//conditions:default": "@cuda_cupti-{{host_platform}}//:lib/libnvperf_target.so",
    }),
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
    shared_library = select({
        "{{PLATFORM_CONSTRAINT}}": "@cuda_nvml_dev-{{PLATFORM}}//:lib/stubs/libnvidia-ml.so",
        "//conditions:default": "@cuda_nvml_dev-{{host_platform}}//:lib/stubs/libnvidia-ml.so",
    }),
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "nvml",
    deps = [
        ":cuda_headers",
    ] + [
        ":nvidia-ml_so",
    ],
)

# curand
cc_import(
    name = "curand_so",
    shared_library = select({
        "{{PLATFORM_CONSTRAINT}}": "@libcurand-{{PLATFORM}}//:lib/stubs/libcurand.so",
        "//conditions:default": "@libcurand-{{host_platform}}//:lib/stubs/libcurand.so",
    }),
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
    static_library = select({
        "{{PLATFORM_CONSTRAINT}}": "@cuda_nvcc-{{PLATFORM}}//:lib/libnvptxcompiler_static.a",
        "//conditions:default": "@cuda_nvcc-{{host_platform}}//:lib/libnvptxcompiler_static.a",
    }),
    target_compatible_with = ["@platforms//os:linux"],
)

#cc_library(
#    name = "nvptxcompiler",
#    srcs = [],
#    hdrs = glob([
#        "cuda/include/fatbinary_section.h",
#        "cuda/include/nvPTXCompiler.h",
#        "cuda/include/crt/*",
#    ]),
#    includes = [
#        "cuda/include",
#    ],
#    visibility = ["//visibility:public"],
#    deps = [] +
#    [
#        ":nvptxcompiler_so"
#    ]
#)

# cufft
cc_import(
    name = "cufft_so",
    shared_library = select({
        "{{PLATFORM_CONSTRAINT}}": "@libcufft-{{PLATFORM}}//:lib/libcufft.so",
        "//conditions:default": "@libcufft-{{host_platform}}//:lib/libcufft.so",
    }),
    target_compatible_with = ["@platforms//os:linux"],
)

#cc_import(
#    name = "cufftw_so",
#    shared_library = "@libcufftw-{{host_platform}}//:lib/libcufftw.so",
#    target_compatible_with = ["@platforms//os:linux"],
#)
#
#cc_import(
#    name = "cufftw_lib",
#    interface_library = "cuda/lib/x64/cufftw.lib",
#    target_compatible_with = ["@platforms//os:windows"],
#)

cc_library(
    name = "cufft",
    deps = [
        ":cuda_headers",
    ] + [
        ":cufft_so",
#        ":cufftw_so"
    ],
)

# cusolver
cc_import(
    name = "cusolver_so",
    shared_library = select({
        "{{PLATFORM_CONSTRAINT}}": "@libcusolver-{{PLATFORM}}//:lib/libcusolver.so",
        "//conditions:default": "@libcusolver-{{host_platform}}//:lib/libcusolver.so",
    }),
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "cusolver",
    deps = [
        ":cuda_headers",
    ] + [
        ":cusolver_so",
    ],
)

# cusparse
cc_import(
    name = "cusparse_so",
    shared_library = select({
        "{{PLATFORM_CONSTRAINT}}": "@libcusparse-{{PLATFORM}}//:lib/libcusparse.so",
        "//conditions:default": "@libcusparse-{{host_platform}}//:lib/libcusparse.so",
    }),
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "cusparse",
    deps = [
        ":cuda_headers",
    ] + [
        ":cusparse_so",
    ],
)

# nvtx
cc_import(
    name = "nvtx_so",
    shared_library = select({
        "{{PLATFORM_CONSTRAINT}}": "@cuda_nvtx-{{PLATFORM}}//:lib/libnvToolsExt.so",
        "//conditions:default": "@cuda_nvtx-{{host_platform}}//:lib/libnvToolsExt.so",
    }),
    target_compatible_with = ["@platforms//os:linux"],
)

cc_library(
    name = "nvtx",
    deps = [
        ":cuda_headers",
    ] + [
        ":nvtx_so",
    ],
)

label_flag(
    name = "runtime",
    build_setting_default = ":cuda_runtime",
)
