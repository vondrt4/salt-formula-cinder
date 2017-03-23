cinder:
  controller:
    enabled: true
    version: liberty
    backend:
      hp3par_backend:
        type_name: hp3par
        engine: hp3par
        backend: hp3par_backend
        user: admin
        password: password  
        url: http://localhost/api/v1
        cpg: OpenStackCPG
        host: localhost
        login: admin
        sanpassword: password
        debug: True
        snapcpg: OpenStackSNAPCPG
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
  volume:
    enabled: true
    version: liberty
    backend:
      hp3par_backend:
        type_name: hp3par
        backend: hp3par_backend
        user: admin
        password: password  
        url: http://localhost/api/v1
        cpg: OpenStackCPG
        host: localhost
        login: admin
        sanpassword: password
        debug: True
        snapcpg: OpenStackSNAPCPG
        engine: hp3par
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
