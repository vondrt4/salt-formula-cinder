{%- if not salt['user.info']('cinder') %}
cinder_user:
  user.present:
    - name: cinder
    - home: /var/lib/cinder
    - uid: 304
    - gid: 304
    - shell: /bin/false
    - system: True
    - require_in:
      {%- if pillar.cinder.controller.enabled is defined and pillar.cinder.controller.enabled %}
      - pkg: cinder_controller_packages
      {%- endif %}
      {%- if pillar.cinder.volume.enabled is defined and pillar.cinder.controller.enabled %}
      - pkg: cinder_volume_packages
      {%- endif %}

cinder_group:
  group.present:
    - name: cinder
    - gid: 304
    - system: True
    - require_in:
      - user: cinder_user
{%- endif %}
