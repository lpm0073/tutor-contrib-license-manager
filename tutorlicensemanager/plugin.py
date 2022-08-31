from glob import glob
import os
import pkg_resources

from tutor import hooks

from .__about__ import __version__


########################################
# CONFIGURATION
########################################

hooks.Filters.CONFIG_DEFAULTS.add_items(
    [
        # Add your new settings that have default values here.
        # Each new setting is a pair: (setting_name, default_value).
        # Prefix your setting names with 'LICENSEMANAGER_'.
        ("LICENSEMANAGER_VERSION", __version__),
    ]
)

hooks.Filters.CONFIG_UNIQUE.add_items(
    [
        # Add settings that don't have a reasonable default for all users here.
        # For instance: passwords, secret keys, etc.
        # Each new setting is a pair: (setting_name, unique_generated_value).
        # Prefix your setting names with 'LICENSEMANAGER_'.
        # For example:
        # ("LICENSEMANAGER_SECRET_KEY", "{{ 24|random_string }}"),
    ]
)

hooks.Filters.CONFIG_OVERRIDES.add_items(
    [
        # Danger zone!
        # Add values to override settings from Tutor core or other plugins here.
        # Each override is a pair: (setting_name, new_value). For example:
        # ("PLATFORM_NAME", "My platform"),
    ]
)


########################################
# INITIALIZATION TASKS
########################################

# To run the script from templates/licensemanager/tasks/myservice/init, add:
# hooks.Filters.COMMANDS_INIT.add_item((
#     "myservice",
#     ("licensemanager", "tasks", "myservice", "init"),
# ))


########################################
# DOCKER IMAGE MANAGEMENT
########################################

# To build an image with `tutor images build myimage`, add a Dockerfile to templates/licensemanager/build/myimage and write:
# hooks.Filters.IMAGES_BUILD.add_item((
#     "myimage",
#     ("plugins", "licensemanager", "build", "myimage"),
#     "docker.io/myimage:{{ LICENSEMANAGER_VERSION }}",
#     (),
# )

# To pull/push an image with `tutor images pull myimage` and `tutor images push myimage`, write:
# hooks.Filters.IMAGES_PULL.add_item((
#     "myimage",
#     "docker.io/myimage:{{ LICENSEMANAGER_VERSION }}",
# )
# hooks.Filters.IMAGES_PUSH.add_item((
#     "myimage",
#     "docker.io/myimage:{{ LICENSEMANAGER_VERSION }}",
# )


########################################
# TEMPLATE RENDERING
# (It is safe & recommended to leave
#  this section as-is :)
########################################

hooks.Filters.ENV_TEMPLATE_ROOTS.add_items(
    # Root paths for template files, relative to the project root.
    [
        pkg_resources.resource_filename("tutorlicensemanager", "templates"),
    ]
)

hooks.Filters.ENV_TEMPLATE_TARGETS.add_items(
    # For each pair (source_path, destination_path):
    # templates at ``source_path`` (relative to your ENV_TEMPLATE_ROOTS) will be
    # rendered to ``destination_path`` (relative to your Tutor environment).
    [
        ("licensemanager/build", "plugins"),
        ("licensemanager/apps", "plugins"),
    ],
)


########################################
# PATCH LOADING
# (It is safe & recommended to leave
#  this section as-is :)
########################################

# For each file in tutorlicensemanager/patches,
# apply a patch based on the file's name and contents.
for path in glob(
    os.path.join(
        pkg_resources.resource_filename("tutorlicensemanager", "patches"),
        "*",
    )
):
    with open(path, encoding="utf-8") as patch_file:
        hooks.Filters.ENV_PATCHES.add_item((os.path.basename(path), patch_file.read()))
