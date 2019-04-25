cinder:
  client:
    enabled: true
    identity:
      host: 127.0.0.1
      port: 35357
      project: service
      user: cinder
      password: pwd
      protocol: http
      endpoint_type: internalURL
      region_name: RegionOne
    backend:
      ceph:
        type_name: standard-iops
        engine: ceph
        key:
          conn_speed: fibre-10G
