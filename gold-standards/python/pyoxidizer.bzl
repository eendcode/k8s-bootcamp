# def make_exe():
#     dist = default_python_distribution()
#     policy = dist.make_python_packaging_policy()

#     # CHANGE: Allow resources to be written to the filesystem
#     # "relative-path:lib" creates a directory named 'lib' next to your exe
#     policy.resources_location_fallback = "filesystem-relative:lib"

#     python_config = dist.make_python_interpreter_config()
#     python_config.run_module = "${ENTRY_MODULE}"

#     exe = dist.to_python_executable(
#         name="py-binary",
#         packaging_policy=policy,
#         config=python_config,
#     )

#     exe.add_python_resources(exe.pip_install(["-r", "requirements.txt"]))
#     exe.add_python_resources(exe.pip_install(["."]))

#     return exe

# register_target("exe", make_exe, default=True)
# resolve_targets()


def make_exe():
    dist = default_python_distribution()
    policy = dist.make_python_packaging_policy()

    # 1. THE STABILITY FIX:
    # This prevents PyOxidizer from trying to re-compile the Python
    # interpreter core, which is where the config.o error happens.
    policy.extension_module_filter = "all"

    # Allow fallback for C-extensions
    policy.resources_location_fallback = "filesystem-relative:lib"

    python_config = dist.make_python_interpreter_config()
    python_config.run_module = "${ENTRY_MODULE}"

    # 2. THE BUILD FIX:
    # We specify the build_mode to ensure it doesn't try to link
    # everything into a single static object if it's failing.
    exe = dist.to_python_executable(
        name="app-binary",
        packaging_policy=policy,
        config=python_config,
    )

    exe.add_python_resources(exe.pip_install(["-r", "requirements.txt"]))

    exe.add_python_resources(exe.read_package_root(path=".", packages=["web"]))

    return exe


register_target("exe", make_exe, default=True)
resolve_targets()
