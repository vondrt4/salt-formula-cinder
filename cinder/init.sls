
include:
{% if pillar.cinder.controller is defined %}
- cinder.controller
{% endif %}
{% if pillar.cinder.compute is defined %}
- cinder.compute
{% endif %}
{% if pillar.cinder.volume is defined %}
- cinder.volume
{% endif %}
