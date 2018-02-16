cinder:
  controller:
    enabled: true
    version: liberty
    osapi:
      host: 127.0.0.1
    database:
      engine: mysql
      host:  localhost
      port: 3306
      name: cinder
      user: cinder
      password: password
    identity:
      engine: keystone
      host: 127.0.0.1
      region: RegionOne
      port: 35357
      tenant: service
      user: cinder
      password: password
      endpoint_type: internalURL
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
    message_queue:
      engine: rabbitmq
      host: 127.0.0.1
      port: 5672
      user: openstack
      password: password
      virtual_host: '/openstack'
    storage:
        engine: storwize
        host: 192.168.0.1
        port: 22
        user: username
        password: pass
    policy:
      'volume:delete': 'rule:admin_or_owner'
      'volume:extend':
