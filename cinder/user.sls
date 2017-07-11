{%- if not salt['user.info']('cinder') %}
cinder_user:
  user.present:
    - name: cinder
    - home: /var/lib/cinder
    {# note: cinder uid/gid values would not be evaluated after user is created. #}
    - uid: {{ user.cinder_uid }}
    - gid: {{ user.cinder_gid }}
    - shell: /bin/false
    - system: True
    - require_in:
      {%- if pillar.cinder.get('controller', {}).get('enabled', False) %}
      - pkg: cinder_controller_packages
      {%- endif %}
      {%- if pillar.cinder.get('volume', {}).get('enabled', False) %}
      - pkg: cinder_volume_packages
      {%- endif %}

cinder_group:
  group.present:
    - name: cinder
    {# note: cinder uid/gid values would not be evaluated after user is created. #}
    - gid: {{ user.cinder_gid }}
    - system: True
    - require_in:
      - user: cinder_user
{%- endif %}
