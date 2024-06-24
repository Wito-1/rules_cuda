# This becomes the BUILD file for @local_cuda//toolchain/ under Linux.

alias(
  name = "cuda-toolkit",
  actual = select({
      "@rules_cuda//cuda:linux-x86_64.constraint": "@cuda-linux-x86_64//toolchain:cuda-toolkit",
      "@rules_cuda//cuda:linux-aarch64.constraint": "@cuda-linux-aarch64//toolchain:cuda-toolkit",
      "@rules_cuda//cuda:linux-sbsa.constraint": "@cuda-linux-sbsa//toolchain:cuda-toolkit",
      "//conditions:default": "@cuda-{{host_platform}}//toolchain:cuda-toolkit",
  }),
)

alias(
  name = "nvcc-config",
  actual = select({
      "@rules_cuda//cuda:linux-x86_64.constraint": "@cuda-linux-x86_64//toolchain:nvcc-config",
      "@rules_cuda//cuda:linux-aarch64.constraint": "@cuda-linux-aarch64//toolchain:nvcc-config",
      "@rules_cuda//cuda:linux-sbsa.constraint": "@cuda-linux-sbsa//toolchain:nvcc-config",
      "//conditions:default": "@cuda-{{host_platform}}//toolchain:nvcc-config",
  }),
)

alias(
  name = "nvcc-compiler-files",
  actual = select({
      "@rules_cuda//cuda:linux-x86_64.constraint": "@cuda-linux-x86_64//toolchain:nvcc-compiler-files",
      "@rules_cuda//cuda:linux-aarch64.constraint": "@cuda-linux-aarch64//toolchain:nvcc-compiler-files",
      "@rules_cuda//cuda:linux-sbsa.constraint": "@cuda-linux-sbsa//toolchain:nvcc-compiler-files",
      "//conditions:default": "@cuda-{{host_platform}}//toolchain:nvcc-compiler-files",
  }),
)

alias(
  name = "nvcc",
  actual = select({
      "@rules_cuda//cuda:linux-x86_64.constraint": "@cuda-linux-x86_64//toolchain:nvcc",
      "@rules_cuda//cuda:linux-aarch64.constraint": "@cuda-linux-aarch64//toolchain:nvcc",
      "@rules_cuda//cuda:linux-sbsa.constraint": "@cuda-linux-sbsa//toolchain:nvcc",
      "//conditions:default": "@cuda-{{host_platform}}//toolchain:nvcc",
  }),
)

alias(
  name = "nvcc-toolchain",
  actual = select({
      "@rules_cuda//cuda:linux-x86_64.constraint": "@cuda-linux-x86_64//toolchain:nvcc-toolchain",
      "@rules_cuda//cuda:linux-aarch64.constraint": "@cuda-linux-aarch64//toolchain:nvcc-toolchain",
      "@rules_cuda//cuda:linux-sbsa.constraint": "@cuda-linux-sbsa//toolchain:nvcc-toolchain",
      "//conditions:default": "@cuda-{{host_platform}}//toolchain:nvcc-toolchain",
  }),
)
