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
    srcs = [
        "@cuda_cudart-{{platform}}//:lib/stubs/libcuda.so"
    ],
    linkopts = [
        "-ldl",
        "-lpthread",
        "-lrt",
    ],
)

cc_library(
    name = "cudart_so",
    srcs = ["@cuda_cudart-{{platform}}//:lib/libcudart.so",],
    target_compatible_with = ["@platforms//os:linux"],
    alwayslink = 1,
)

cc_library(
    name = "cudadevrt_a",
    srcs = ["@cuda_cudart-{{platform}}//:lib/libcudadevrt.a"],
    target_compatible_with = ["@platforms//os:linux"],
    alwayslink = 1,
)

cc_import(
    name = "cudart_lib",
    interface_library = "@cuda_cudart-{{platform}}//:cuda/lib/x64/cudart.lib",
    target_compatible_with = ["@platforms//os:windows"],
)

cc_import(
    name = "cudadevrt_lib",
    interface_library = "@cuda_cudart-{{platform}}//:cuda/lib/x64/cudadevrt.lib",
    target_compatible_with = ["@platforms//os:windows"],
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

cc_import(
    name = "cuda_so",
    shared_library = "@cuda_cudart-{{platform}}//:lib/stubs/libcuda.so",
    target_compatible_with = ["@platforms//os:linux"],
)

cc_import(
    name = "cuda_lib",
    interface_library = "@cuda_cudart-{{platform}}//:cuda/lib/x64/cuda.lib",
    target_compatible_with = ["@platforms//os:windows"],
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
    shared_library = "@libcublas-{{platform}}//:lib/libcublas.so",
    target_compatible_with = ["@platforms//os:linux"],
)

cc_import(
    name = "cublasLt_so",
    shared_library = "@libcublas-{{platform}}//:lib/libcublasLt.so",
    target_compatible_with = ["@platforms//os:linux"],
)

cc_import(
    name = "cublas_lib",
    interface_library = "@libcublas-{{platform}}//:cuda/lib/x64/cublas.lib",
    target_compatible_with = ["@platforms//os:windows"],
)

cc_import(
    name = "cublasLt_lib",
    interface_library = "@libcublas-{{platform}}//:cuda/lib/x64/cublasLt.lib",
    target_compatible_with = ["@platforms//os:windows"],
)

cc_library(
    name = "cublas",
    deps = [
        ":cuda_runtime",
        "@libcublas-{{platform}}//:hdrs",
    ] + [
        ":cublasLt_so",
        ":cublas_so",
    ],
)

# CUPTI
cc_import(
    name = "cupti_so",
    shared_library = "@cuda_cupti-{{platform}}//:lib/libcupti.so",
    target_compatible_with = ["@platforms//os:linux"],
)

cc_import(
    name = "cupti_lib",
    interface_library = "@cuda_cupti-{{platform}}//:cuda/extras/CUPTI/lib64/cupti.lib",
    target_compatible_with = ["@platforms//os:windows"],
)

#cc_library(
#    name = "cupti_headers",
#    hdrs = glob(["cuda/extras/CUPTI/include/*.h"]),
#    includes = ["cuda/extras/CUPTI/include"],
#)

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
    shared_library = "@cuda_cupti-{{platform}}//:lib/libnvperf_host.so",
    target_compatible_with = ["@platforms//os:linux"],
)

cc_import(
    name = "nvperf_host_lib",
    interface_library = "cuda/extras/CUPTI/lib64/nvperf_host.lib",
    target_compatible_with = ["@platforms//os:windows"],
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

cc_import(
    name = "nvperf_target_lib",
    interface_library = "cuda/extras/CUPTI/lib64/nvperf_target.lib",
    target_compatible_with = ["@platforms//os:windows"],
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

cc_import(
    name = "nvml_lib",
    interface_library = "cuda/lib/x64/nvml.lib",
    target_compatible_with = ["@platforms//os:windows"],
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
    shared_library = "@libcurand-{{platform}}//:lib/stubs/libcurand.so",
    target_compatible_with = ["@platforms//os:linux"],
)

cc_import(
    name = "curand_lib",
    interface_library = "cuda/lib/x64/curand.lib",
    target_compatible_with = ["@platforms//os:windows"],
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

cc_import(
    name = "nvptxcompiler_lib",
    interface_library = "cuda/lib/x64/nvptxcompiler_static.lib",
    target_compatible_with = ["@platforms//os:windows"],
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
    shared_library = "@libcufft-{{platform}}//:lib/libcufft.so",
    target_compatible_with = ["@platforms//os:linux"],
)

cc_import(
    name = "cufft_lib",
    interface_library = "cuda/lib/x64/cufft.lib",
    target_compatible_with = ["@platforms//os:windows"],
)

#cc_import(
#    name = "cufftw_so",
#    shared_library = "@libcufftw-{{platform}}//:lib/libcufftw.so",
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
    shared_library = "@libcusolver-{{platform}}//:lib/libcusolver.so",
    target_compatible_with = ["@platforms//os:linux"],
)

cc_import(
    name = "cusolver_lib",
    interface_library = "cuda/lib/x64/cusolver.lib",
    target_compatible_with = ["@platforms//os:windows"],
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
    shared_library = "@libcusparse-{{platform}}//:lib/libcusparse.so",
    target_compatible_with = ["@platforms//os:linux"],
)

cc_import(
    name = "cusparse_lib",
    interface_library = "cuda/lib/x64/cusparse.lib",
    target_compatible_with = ["@platforms//os:windows"],
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
    shared_library = "@cuda_nvtx-{{platform}}//:lib/libnvToolsExt.so",
    target_compatible_with = ["@platforms//os:linux"],
)

cc_import(
    name = "nvtx_lib",
    interface_library = "cuda/lib/x64/libnvToolsExt.lib",
    target_compatible_with = ["@platforms//os:windows"],
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
