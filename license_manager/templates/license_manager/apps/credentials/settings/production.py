from license_manager.settings.production import * # pylint: disable=wildcard-import, unused-wildcard-import

{% include "license_manager/apps/license_manager/settings/partials/common.py" %}

SOCIAL_AUTH_EDX_OAUTH2_PUBLIC_URL_ROOT = "{% if ENABLE_HTTPS %}https{% else %}http{% endif %}://{{ LMS_HOST }}"

BACKEND_SERVICE_EDX_OAUTH2_KEY = "{{ LICENSE_MANAGER_OAUTH2_KEY }}"

{{ patch("license_manager-settings-production") }}
