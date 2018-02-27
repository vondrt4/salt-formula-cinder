cinder:
  controller:
    enabled: true
    version: liberty
    backend:
      ceph_backend:
        type_name: standard-iops
        backend: ceph_backend
        pool: volumes
        engine: ceph
        user: cinder
        secret_uuid: password
        client_cinder_key: password
    identity:
      engine: keystone
      host: 127.0.0.1
      port: 35357
      tenant: service
      user: cinder
      password: pwd
      region: regionOne
    osapi:
      host: 127.0.0.1
    osapi_max_limit: 500
    glance:
        host: 127.0.0.1
        port: 9292
    logging:
      log_appender: false
      log_handlers:
        watchedfile:
          enabled: true
        fluentd:
          enabled: false
        ossyslog:
          enabled: false
    default_volume_type: 7k2SaS
    message_queue:
      engine: rabbitmq
      host: 127.0.0.1
      port: 5672
      user: openstack
      password: pwd
      virtual_host: '/openstack'
    database:
      engine: mysql
      host: 127.0.0.1
      port: 3306
      name: cinder
      user: cinder
      password: pwd
    policy:
      'volume:delete': 'rule:admin_or_owner'
      'volume:extend':
  volume:
    enabled: true
    version: liberty
    backend:
      ceph_backend:
        type_name: standard-iops
        backend: ceph_backend
        pool: volumes
        engine: ceph
        user: cinder
        secret_uuid: password
        client_cinder_key: password
    identity:
      engine: keystone
      host: 127.0.0.1
      port: 35357
      tenant: service
      user: cinder
      password: pwd
      region: regionOne
    osapi:
        host: 127.0.0.1
    glance:
        host: 127.0.0.1
        port: 9292
    default_volume_type: 7k2SaS
    message_queue:
      engine: rabbitmq
      host: 127.0.0.1
      port: 5672
      user: openstack
      password: pwd
      virtual_host: '/openstack'
    database:
      engine: mysql
      host: 127.0.0.1
      port: 3306
      name: cinder
      user: cinder
      password: pwd
