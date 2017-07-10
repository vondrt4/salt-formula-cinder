
include:
{% if pillar.cinder.controller is defined %}
- cinder.controller
{% endif %}
{% if pillar.cinder.volume is defined %}
- cinder.volume
{% endif %}
{% if pillar.cinder.client is defined %}
- cinder.client
{% endif %}
