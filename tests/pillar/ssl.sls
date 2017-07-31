include:
  - .ceph_single
cinder:
  controller:
    message_queue:
      port: 5671
      ssl:
        enabled: True
  volume:
    message_queue:
      port: 5671
      ssl:
        enabled: True
