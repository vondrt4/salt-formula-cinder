cinder:
  controller:
    enabled: true
    version: liberty
    default_volume_type: nfs-driver
    message_queue:
      engine: rabbitmq
      host: 127.0.0.1
      port: 5672
      user: openstack
      password: pwd
      virtual_host: '/openstack'
    identity:
      engine: keystone
      host: 127.0.0.1
      port: 35357
      tenant: service
      user: cinder
      password: pwd
      region: regionOne
    backend:
      nfs-driver:
        engine: nfs
        type_name: nfs-driver
        volume_group: cinder-volume
        path: /var/lib/cinder/nfs
        devices:
        - 172.16.10.110:/var/nfs/cinder
        options: rw,sync
  volume:
    enabled: true
    version: liberty
    default_volume_type: nfs-driver
    message_queue:
      engine: rabbitmq
      host: 127.0.0.1
      port: 5672
      user: openstack
      password: pwd
      virtual_host: '/openstack'
    backend:
      nfs-driver:
        enabled: true
        engine: nfs
        type_name: nfs-driver
        volume_group: cinder-volume
