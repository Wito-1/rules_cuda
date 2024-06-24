package(
    default_visibility = ["//visibility:public"],
)

alias(
    name = "cuda_headers",
    actual = select({
        "{{PLATFORM_CONSTRAINT}}": "@{{PLATFORM_REPO}}//:cuda_headers",
    }),
)

alias(
    name = "cuda_stub",
    actual = select({
        "{{PLATFORM_CONSTRAINT}}": "@{{PLATFORM_REPO}}//:cuda_stub",
    }),
)

# Note: do not use this target directly, use the configurable label_flag
# @rules_cuda//cuda:runtime instead.
alias(
    name = "cuda_runtime",
    actual = select({
        "{{PLATFORM_CONSTRAINT}}": "@{{PLATFORM_REPO}}//:cuda_runtime",
    }),
)

# Note: do not use this target directly, use the configurable label_flag
# @rules_cuda//cuda:runtime instead.
alias(
    name = "cuda_runtime_static",
    actual = select({
        "{{PLATFORM_CONSTRAINT}}": "@{{PLATFORM_REPO}}//:cuda_runtime_static",
    }),
)

alias(
    name = "no_cuda_runtime",
    actual = select({
        "{{PLATFORM_CONSTRAINT}}": "@{{PLATFORM_REPO}}//:no_cuda_runtime",
    })
)

alias(
    name = "cuda",
    actual = select({
        "{{PLATFORM_CONSTRAINT}}": "@{{PLATFORM_REPO}}//:cuda",
    }),
)

alias(
    name = "cublas",
    actual = select({
        "{{PLATFORM_CONSTRAINT}}": "@{{PLATFORM_REPO}}//:cublas",
    })
)

# CUPTI
alias(
    name = "cupti",
    actual = select({
        "{{PLATFORM_CONSTRAINT}}": "@{{PLATFORM_REPO}}//:cupti",
    }),
)

# nvperf
alias(
    name = "nvperf_host",
    actual = select({
        "{{PLATFORM_CONSTRAINT}}": "@{{PLATFORM_REPO}}//:nvperf_host",
    }),
)

alias(
    name = "nvperf_target",
    actual = select({
        "{{PLATFORM_CONSTRAINT}}": "@{{PLATFORM_REPO}}//:nvperf_target",
    }),
)

alias(
    name = "nvml",
    actual = select({
        "{{PLATFORM_CONSTRAINT}}": "@{{PLATFORM_REPO}}//:nvml",
    }),
)

alias(
    name = "curand",
    actual = select({
        "{{PLATFORM_CONSTRAINT}}": "@{{PLATFORM_REPO}}//:curand",
    }),
)

# cufft
alias(
    name = "cufft",
    actual = select({
        "{{PLATFORM_CONSTRAINT}}": "@{{PLATFORM_REPO}}//:cufft",
    }),
)

# cusolver
alias(
    name = "cusolver",
    actual = select({
        "{{PLATFORM_CONSTRAINT}}": "@{{PLATFORM_REPO}}//:cusolver",
    }),
)

# cusparse
alias(
    name = "cusparse",
    actual = select({
        "{{PLATFORM_CONSTRAINT}}": "@{{PLATFORM_REPO}}//:cusparse",
    }),
)

# nvtx
alias(
    name = "nvtx",
    actual = select({
        "{{PLATFORM_CONSTRAINT}}": "@{{PLATFORM_REPO}}//:nvtx",
    }),
)

alias(
    name = "runtime",
    actual = select({
        "{{PLATFORM_CONSTRAINT}}": "@{{PLATFORM_REPO}}//:runtime",
    }),
)
