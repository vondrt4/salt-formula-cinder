cinder:
  controller:
    enabled: true
    version: liberty
    default_volume_type: nfs-driver
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
    backend:
      nfs-driver:
        enabled: true
        engine: nfs
        type_name: nfs-driver
        volume_group: cinder-volume