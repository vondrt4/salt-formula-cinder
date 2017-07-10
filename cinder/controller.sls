{%- from "cinder/map.jinja" import controller with context %}
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

{%- if controller.version == 'ocata' %}

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

{# new way #}
{%- if not grains.get('noservices', False) %}

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
  cmd.run:
  - name: "source /root/keystonerc; cinder type-create {{ backend.type_name }}"
  - unless: "source /root/keystonerc; cinder type-list | grep {{ backend.type_name }}"
  - shell: /bin/bash
  - require:
    - service: cinder_controller_services

cinder_type_update_{{ backend_name }}:
  cmd.run:
  - name: "source /root/keystonerc; cinder type-key {{ backend.type_name }} set volume_backend_name={{ backend_name }}"
  - unless: "source /root/keystonerc; cinder extra-specs-list | grep \"{u'volume_backend_name': u'{{ backend_name }}'}\""
  - shell: /bin/bash
  - require:
    - cmd: cinder_type_create_{{ backend_name }}

{%- endfor %}

{%- endif %}

{# old way #}

{% for type in controller.get('types', []) %}

cinder_type_create_{{ type.name }}:
  cmd.run:
  - name: "source /root/keystonerc; cinder type-create {{ type.name }}"
  - unless: "source /root/keystonerc; cinder type-list | grep {{ type.name }}"
  - shell: /bin/bash
  - require:
    - service: cinder_controller_services

cinder_type_update_{{ type.name }}:
  cmd.run:
  - name: "source /root/keystonerc; cinder type-key {{ type.name }} set volume_backend_name={{ type.get('backend', type.name) }}"
  - unless: "source /root/keystonerc; cinder extra-specs-list | grep \"{u'volume_backend_name': u'{{ type.get('backend', type.name) }}'}\""
  - shell: /bin/bash
  - require:
    - cmd: cinder_type_create_{{ type.name }}

{% endfor %}

{%- if controller.backup.engine != None %}

cinder_backup_packages:
  pkg.installed:
  - names: {{ controller.backup.pkgs }}

cinder_backup_services:
  service.running:
  - names: {{ controller.backup.services }}
  - enable: true
  - watch:
    - file: /etc/cinder/cinder.conf
    - file: /etc/cinder/api-paste.ini

{%- endif %}

{%- endif %}
