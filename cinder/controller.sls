{%- from "cinder/map.jinja" import controller, system_cacerts_file with context %}
{%- if controller.get('enabled', False) %}

{%- set user = controller %}
{%- include "cinder/user.sls" %}

cinder_controller_packages:
  pkg.installed:
  - names: {{ controller.pkgs }}

/etc/cinder/cinder.conf:
  file.managed:
  - source: salt://cinder/files/{{ controller.version }}/cinder.conf.controller.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: cinder_controller_packages

/etc/cinder/api-paste.ini:
  file.managed:
  - source: salt://cinder/files/{{ controller.version }}/api-paste.ini.controller.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: cinder_controller_packages

{%- for name, rule in controller.get('policy', {}).iteritems() %}

{%- if rule != None %}
rule_{{ name }}_present:
  keystone_policy.rule_present:
  - path: /etc/cinder/policy.json
  - name: {{ name }}
  - rule: {{ rule }}
  - require:
    - pkg: cinder_controller_packages

{%- else %}

rule_{{ name }}_absent:
  keystone_policy.rule_absent:
  - path: /etc/cinder/policy.json
  - name: {{ name }}
  - require:
    - pkg: cinder_controller_packages

{%- endif %}

{%- endfor %}

{%- if controller.version in ('ocata','pike') %}

/etc/apache2/conf-available/cinder-wsgi.conf:
  file.managed:
  - source: salt://cinder/files/{{ controller.version }}/cinder-wsgi.conf
  - template: jinja
  - require:
    - pkg: cinder_controller_packages

cinder_api_service:
  service.running:
  - name: apache2
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - watch:
    {%- if controller.message_queue.get('ssl',{}).get('enabled', False) %}
    - file: rabbitmq_ca
    {%- endif %}
    {%- if controller.database.get('ssl',{}).get('enabled', False) %}
    - file: mysql_ca_cinder_controller
    {%- endif %}
    - file: /etc/cinder/cinder.conf
    - file: /etc/cinder/api-paste.ini
    - file: /etc/apache2/conf-available/cinder-wsgi.conf

{%- else %}

cinder_api_service:
  service.running:
  - name: cinder-api
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - watch:
    {%- if controller.message_queue.get('ssl',{}).get('enabled', False) %}
    - file: rabbitmq_ca
    {%- endif %}
    {%- if controller.database.get('ssl',{}).get('enabled', False) %}
    - file: mysql_ca_cinder_controller
    {%- endif %}
    - file: /etc/cinder/cinder.conf
    - file: /etc/cinder/api-paste.ini

{%- endif %}


{%- if grains.get('virtual_subtype', None) == "Docker" %}

cinder_entrypoint:
  file.managed:
  - name: /entrypoint.sh
  - template: jinja
  - source: salt://cinder/files/entrypoint.sh
  - mode: 755

{%- endif %}

cinder_controller_services:
  service.running:
  - names: {{ controller.services }}
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - watch:
    {%- if controller.message_queue.get('ssl',{}).get('enabled', False) %}
    - file: rabbitmq_ca
    {%- endif %}
    {%- if controller.database.get('ssl',{}).get('enabled', False) %}
    - file: mysql_ca_cinder_controller
    {%- endif %}
    - file: /etc/cinder/cinder.conf
    - file: /etc/cinder/api-paste.ini

cinder_syncdb:
  cmd.run:
  - name: 'cinder-manage db sync; sleep 5;'
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - service: cinder_controller_services

{%- if not grains.get('noservices', False) %}

{%- set identity = controller.identity %}
{%- set credentials = {'host': identity.host,
                       'user': identity.user,
                       'password': identity.password,
                       'project_id': identity.tenant,
                       'port': identity.get('port', 35357),
                       'protocol': identity.get('protocol', 'http'),
                       'region_name': identity.get('region_name', 'RegionOne'),
                       'endpoint_type': identity.get('endpoint_type', 'internalURL'),
                       'certificate': identity.get('certificate', 'None')} %}

{%- for backend_name, backend in controller.get('backend', {}).iteritems() %}

{%- if backend.engine is defined and backend.engine == 'nfs' or (backend.engine == 'netapp' and backend.storage_protocol == 'nfs') %}
/etc/cinder/nfs_shares_{{ backend_name }}:
  file.managed:
  - source: salt://cinder/files/{{ controller.version }}/nfs_shares
  - defaults:
      backend: {{ backend|yaml }}
  - template: jinja
  - require:
    - pkg: cinder_controller_packages

cinder_netapp_packages:
  pkg.installed:
    - pkgs:
      - nfs-common

{%- endif %}

{%- if backend.get('use_multipath_for_image_xfer', False) %}

cinder_netapp_add_packages:
  pkg.installed:
    - pkgs:
      - multipath-tools

{%- endif %}

cinder_type_create_{{ backend_name }}:
  cinderng.volume_type_present:
  - name: {{ backend.type_name }}
  - profile: {{ credentials }}
  - require:
    - service: cinder_controller_services

cinder_type_update_{{ backend_name }}:
  cinderng.volume_type_key_present:
  - name: {{ backend.type_name }}
  - key: volume_backend_name
  - value: {{ backend_name }}
  - profile: {{ credentials }}
  - require:
    - cinderng: cinder_type_create_{{ backend_name }}

{%- endfor %}

{%- endif %}

{%- if controller.backup.engine != None %}

cinder_backup_packages:
  pkg.installed:
  - names: {{ controller.backup.pkgs }}

cinder_backup_services:
  service.running:
  - names: {{ controller.backup.services }}
  - enable: true
  - watch:
    {%- if controller.message_queue.get('ssl',{}).get('enabled', False) %}
    - file: rabbitmq_ca
    {%- endif %}
    - file: /etc/cinder/cinder.conf
    - file: /etc/cinder/api-paste.ini

{%- endif %}

{%- if controller.message_queue.get('ssl',{}).get('enabled', False) %}
rabbitmq_ca:
{%- if controller.message_queue.ssl.cacert is defined %}
  file.managed:
    - name: {{ controller.message_queue.ssl.cacert_file }}
    - contents_pillar: cinder:controller:message_queue:ssl:cacert
    - mode: 0444
    - makedirs: true
{%- else %}
  file.exists:
   - name: {{ controller.message_queue.ssl.get('cacert_file', system_cacerts_file) }}
{%- endif %}
{%- endif %}

{%- if controller.database.get('ssl',{}).get('enabled', False) %}
mysql_ca_cinder_controller:
{%- if controller.database.ssl.cacert is defined %}
  file.managed:
    - name: {{ controller.database.ssl.cacert_file }}
    - contents_pillar: cinder:controller:database:ssl:cacert
    - mode: 0444
    - makedirs: true

{%- else %}
  file.exists:
   - name: {{ controller.database.ssl.get('cacert_file', system_cacerts_file) }}
{%- endif %}
{%- endif %}


{%- endif %}
