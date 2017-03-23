cinder:
  volume:
    enabled: true
    version: liberty
    backend:
      10kThinPro:
        type_name: 10kThinPro
        engine: fujitsu
        pool: 10kThinPro
        host: 127.0.0.1
        port: 5988
        user: username
        password: password
        connection: FC
        name: 10kThinPro
      10k_SAS:
        type_name: 10k_SAS
        pool: SAS10K
        engine: fujitsu
        host: 127.0.0.1
        port: 5988
        user: username
        password: password
        connection: FC
        name: 7k2RAID6
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
  controller:
    enabled: true
    version: liberty
    backend:
      10kThinPro:
        type_name: 10kThinPro
        engine: fujitsu
        pool: 10kThinPro
        host: 127.0.0.1
        port: 5988
        user: username
        password: password
        connection: FC
        name: 10kThinPro
      10k_SAS:
        type_name: 10k_SAS
        pool: SAS10K
        engine: fujitsu
        host: 127.0.0.1
        port: 5988
        user: username
        password: password
        connection: FC
        name: 7k2RAID6
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
