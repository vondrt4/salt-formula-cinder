{%- from "cinder/map.jinja" import volume with context %}
{%- if volume.enabled is defined and volume.enabled %}

include:
- cinder.user

cinder_volume_packages:
  pkg.installed:
  - names: {{ volume.pkgs }}

/var/lock/cinder:
  file.directory:
  - mode: 755
  - user: cinder
  - group: cinder
  - require:
    - pkg: cinder_volume_packages
  - require_in:
    - service: cinder_volume_services

{%- if pillar.cinder.controller.enabled is not defined or not pillar.cinder.controller.enabled %}

/etc/cinder/cinder.conf:
  file.managed:
  - source: salt://cinder/files/{{ volume.version }}/cinder.conf.volume.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: cinder_volume_packages

/etc/cinder/api-paste.ini:
  file.managed:
  - source: salt://cinder/files/{{ volume.version }}/api-paste.ini.volume.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: cinder_volume_packages

{%- endif %}

cinder_volume_services:
  service.running:
  - names: {{ volume.services }}
  - enable: true
  - watch:
    - file: /etc/cinder/cinder.conf
    - file: /etc/cinder/api-paste.ini

{%- if volume.notification %}

cinder_metering_cron:
  file.managed:
  - name: /etc/cron.hourly/cinder-volume-usage-audit
  - source: salt://cinder/files/cinder-volume-usage-audit.cron
  - mode: 755
  - template: jinja

{%- endif %}

{%- if volume.storage.engine == 'iscsi' %}

cinder_iscsi_packages:
  pkg.installed:
  - names:
    - iscsitarget
    - open-iscsi
    - iscsitarget-dkms
  - require:
    - pkg: cinder_volume_packages

/etc/default/iscsitarget:
  file.managed:
  - source: salt://cinder/files/iscsitarget
  - template: jinja
  - require:
    - pkg: cinder_iscsi_packages

cinder_scsi_service:
  service.running:
  - names:
    - iscsitarget
    - open-iscsi
  - enable: true
  - watch:
    - file: /etc/default/iscsitarget

{%- endif %}

{%- if volume.storage.engine == 'hitachi_vsp' %}

{%- if grains.os_family == 'Debian' and volume.version == 'juno' %}

hitachi_pkgs:
  pkg.latest:
    - names:
      - horcm
      - hbsd

cinder_hitachi_vps_dir:
  file.directory:
  - name: /var/lock/hbsd
  - user: cinder
  - group: cinder

{%- endif %}

{%- endif %}

{%- if volume.storage.engine == 'hp3par' %}

hp3parclient:
  pkg.latest:
    - name: python-hp3parclient

{%- endif %}

{%- if volume.storage.engine == 'fujitsu' %}

cinder_driver_fujitsu:
  pkg.latest:
    - name: cinder-driver-fujitsu

{%- for type in volume.get('types', []) %}

/etc/cinder/cinder_fujitsu_eternus_dx_{{ type.name }}.xml:
  file.managed:
  - source: salt://cinder/files/{{ volume.version }}/cinder_fujitsu_eternus_dx.xml
  - template: jinja
  - defaults:
      volume_type_name: "{{ type.pool }}"
  - require:
    - pkg: cinder-driver-fujitsu

{%- endfor %}

{%- endif %}

{%- endif %}
