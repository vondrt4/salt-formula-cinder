{%- from "cinder/map.jinja" import compute with context %}
{%- if compute.get('enabled', False) %}

include:
- cinder.user

{%- for backend_name, backend in compute.get('backend', {}).iteritems() %}

{%- if backend.engine is defined and backend.engine == 'nfs' or (backend.engine == 'netapp' and backend.storage_protocol == 'nfs') %}

cinder_netapp_compute_packages:
  pkg.installed:
    - pkgs:
      - nfs-common

{%- endif %}

{%- endfor %}

{%- endif %}
