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
        nas_secure_file_operations: false
        nas_secure_file_permissions: false
        devices:
          - 172.18.2.2:/vol_1
          - 172.18.2.2:/vol_2
          - 172.18.2.2:/vol_3
          - 172.18.2.2:/vol_4
  volume:
    enabled: true
    version: mitaka
linux:
  system:
    package:
      nfs-common:
        version: latest
