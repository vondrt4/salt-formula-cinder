{%- from "cinder/map.jinja" import client with context %}
{%- if client.get('enabled', False) %}

cinder_client_packages:
  pkg.installed:
  - names: {{ client.pkgs }}

{% if client.identity is mapping %}
{%- set identity = client.identity %}
{%- else %}
{%- set identity = salt['pillar.get']('keystone:client:server:'+client.identity) %}
{%- endif %}

{%- set credentials = {'host': identity.host,
                       'user': identity.user,
                       'password': identity.password,
                       'project_id': identity.project,
                       'port': identity.get('port', 35357),
                       'protocol': identity.get('protocol', 'http'),
                       'region_name': identity.get('region_name', 'RegionOne'),
                       'endpoint_type': identity.get('endpoint_type', 'internalURL'),
                       'certificate': identity.get('certificate', client.cacert_file)} %}

{%- for backend_name, backend in client.get('backend', {}).iteritems() %}

cinder_type_create_{{ backend_name }}:
  cinderng.volume_type_present:
  - name: {{ backend.type_name }}
  - profile: {{ credentials }}
  - require:
    - pkg: cinder_client_packages

cinder_type_update_{{ backend_name }}:
  cinderng.volume_type_key_present:
  - name: {{ backend.type_name }}
  - key: volume_backend_name
  - value: {{ backend_name }}
  - profile: {{ credentials }}
  - require:
    - cinderng: cinder_type_create_{{ backend_name }}

{%- for key_name, key_value in backend.get('key', {}).iteritems() %}

cinder_type_update_{{ backend_name }}_{{ key_name }}:
  cinderng.volume_type_key_present:
  - name: {{ backend.type_name }}
  - key: {{ key_name }}
  - value: {{ key_value }}
  - profile: {{ credentials }}
  - require:
    - cinderng: cinder_type_create_{{ backend_name }}

{%- endfor %}

{%- endfor %}

{%- endif %}
