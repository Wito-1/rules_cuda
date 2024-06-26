"""private"""

def _requires_rules_are_enabled():
    return select({
        "@rules_cuda//cuda:is_enabled": [],
        "//conditions:default": ["@rules_cuda//cuda:rules_are_enabled"],
    })

def requires_cuda():
    """Returns constraint_setting that is satisfied if:

    * rules are enabled and

    Add to 'target_compatible_with' attribute to mark a target incompatible when
    the conditions are not satisfied. Incompatible targets are excluded
    from bazel target wildcards and fail to build if requested explicitly.
    """
    return _requires_rules_are_enabled()
