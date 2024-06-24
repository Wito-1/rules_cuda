"""
Macros to add the runtime library as a default dependency to cuda_library() rules.
"""

load("@rules_cuda//cuda/private:rules/cuda_objects.bzl", _cuda_objects = "cuda_objects")
load("@rules_cuda//cuda/private:rules/cuda_library.bzl", _cuda_library = "cuda_library")
load("@rules_cuda//cuda/private:macros/cuda_binary.bzl", _cuda_binary = "cuda_binary")
load("@rules_cuda//cuda/private:macros/cuda_test.bzl", _cuda_test = "cuda_test")
load("@rules_cuda//cuda/private:defs.bzl", _requires_cuda = "requires_cuda")
load("@rules_cuda//cuda/private:os_helpers.bzl", _if_linux = "if_linux", _if_windows = "if_windows")

def cuda_objects(**kwargs):
    deps = kwargs.pop("deps", []) + [Label("//:runtime")]
    _cuda_objects(deps = deps, **kwargs)

def cuda_library(**kwargs):
    deps = kwargs.pop("deps", []) + [Label("//:runtime")]
    _cuda_library(deps = deps, **kwargs)

def cuda_binary(**kwargs):
    deps = kwargs.pop("deps", []) + [Label("//:runtime")]
    _cuda_binary(deps = deps, **kwargs)

def cuda_test(**kwargs):
    deps = kwargs.pop("deps", []) + [Label("//:runtime")]
    _cuda_test(deps = deps, **kwargs)

if_linux = _if_linux
if_windows = _if_windows
requires_cuda = _requires_cuda
