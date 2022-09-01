from license_manager.settings.production import * # pylint: disable=wildcard-import, unused-wildcard-import

{% include "license_manager/apps/license_manager/settings/partials/common.py" %}

# FIX NOTE: confirm whether License Manager uses MFE.
CORS_ORIGIN_WHITELIST = list(CORS_ORIGIN_WHITELIST) + [
    "{% if ENABLE_HTTPS %}https{% else %}http{% endif %}://{{ MFE_HOST }}",
]
CSRF_TRUSTED_ORIGINS = ["{{ MFE_HOST }}"]

SOCIAL_AUTH_EDX_OAUTH2_PUBLIC_URL_ROOT = "{% if ENABLE_HTTPS %}https{% else %}http{% endif %}://{{ LMS_HOST }}"

BACKEND_SERVICE_EDX_OAUTH2_KEY = "{{ LICENSE_MANAGER_OAUTH2_KEY }}"

{{ patch("license-manager-settings-production") }}
