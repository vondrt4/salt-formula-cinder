cinder:
  controller:
    enabled: true
    version: mitaka
    backend:
      netapp:
        engine: netapp
        type_name: netapp
        user: openstack
        vserver: vm1
        server_hostname: 172.18.2.3
        password: password
        storage_protocol: nfs
        transport_type: https
        netapp_lun_space_reservation: enabled
        use_multipath_for_image_xfer: True
        devices:
          - 172.18.2.2:/vol_1
          - 172.18.2.2:/vol_2
          - 172.18.2.2:/vol_3
          - 172.18.2.2:/vol_4
  volume:
    enabled: true
    version: mitaka
  compute:
    enabled: true
    version: mitaka
    backend:
      netapp:
        engine: netapp
        storage_protocol: nfs
