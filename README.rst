==============================
Openstack Cinder Block Storage
==============================

Cinder provides an infrastructure for managing volumes in OpenStack. It was
originally a Nova component called nova-volume, but has become an independent
project since the Folsom release.

Sample pillars
==============

New structure divides cinder-api,cinder-scheduler to role controller and
cinder-volume to role volume.

.. code-block:: yaml

    cinder:
      controller:
        enabled: true
        version: juno
        cinder_uid: 304
        cinder_gid: 304
        nas_secure_file_permissions: false
        nas_secure_file_operations: false
        cinder_internal_tenant_user_id: f46924c112a14c80ab0a24a613d95eef
        cinder_internal_tenant_project_id: b7455b8974bb4064ad247c8f375eae6c
        default_volume_type: 7k2SaS
        enable_force_upload: true
        availability_zone_fallback: True
        database:
          engine: mysql
          host: 127.0.0.1
          port: 3306
          name: cinder
          user: cinder
          password: pwd
        identity:
          engine: keystone
          host: 127.0.0.1
          port: 35357
          tenant: service
          user: cinder
          password: pwd
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        backend:
          7k2_SAS:
            engine: storwize
            type_name: slow-disks
            host: 192.168.0.1
            port: 22
            user: username
            password: pass
            connection: FC/iSCSI
            multihost: true
            multipath: true
            pool: SAS7K2
        audit:
          enabled: false
        osapi_max_limit: 500
        barbican:
          enabled: true

    cinder:
      volume:
        enabled: true
        version: juno
        cinder_uid: 304
        cinder_gid: 304
        nas_secure_file_permissions: false
        nas_secure_file_operations: false
        cinder_internal_tenant_user_id: f46924c112a14c80ab0a24a613d95eef
        cinder_internal_tenant_project_id: b7455b8974bb4064ad247c8f375eae6c
        default_volume_type: 7k2SaS
        nable_force_upload: true
        database:
          engine: mysql
          host: 127.0.0.1
          port: 3306
          name: cinder
          user: cinder
          password: pwd
        identity:
          engine: keystone
          host: 127.0.0.1
          port: 35357
          tenant: service
          user: cinder
          password: pwd
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        backend:
          7k2_SAS:
            engine: storwize
            type_name: 7k2 SAS disk
            host: 192.168.0.1
            port: 22
            user: username
            password: pass
            connection: FC/iSCSI
            multihost: true
            multipath: true
            pool: SAS7K2
        audit:
          enabled: false
        barbican:
          enabled: true


Volume vmware related options:

.. code-block:: yaml

    cinder:
      volume:
        backend:
          vmware:
            engine: vmware
            host_username: vmware
            host_password: vmware
            cluster_names: vmware_cluster01,vmware_cluster02


Enable CORS parameters

.. code-block:: yaml

    cinder:
      controller:
        cors:
          allowed_origin: https:localhost.local,http:localhost.local
          expose_headers: X-Auth-Token,X-Openstack-Request-Id,X-Subject-Token
          allow_methods: GET,PUT,POST,DELETE,PATCH
          allow_headers: X-Auth-Token,X-Openstack-Request-Id,X-Subject-Token
          allow_credentials: True
          max_age: 86400

Client-side RabbitMQ HA setup for controller

.. code-block:: yaml

    cinder:
      controller:
        ....
        message_queue:
          engine: rabbitmq
          members:
            - host: 10.0.16.1
            - host: 10.0.16.2
            - host: 10.0.16.3
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        ....

Client-side RabbitMQ HA setup for volume component

.. code-block:: yaml

    cinder:
      volume:
        ....
        message_queue:
          engine: rabbitmq
          members:
            - host: 10.0.16.1
            - host: 10.0.16.2
            - host: 10.0.16.3
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        ....


Configuring TLS communications
------------------------------


**Note:** by default system wide installed CA certs are used, so ``cacert_file`` param is optional, as well as ``cacert``.


- **RabbitMQ TLS**

.. code-block:: yaml

 cinder:
   controller, volume:
      message_queue:
        port: 5671
        ssl:
          enabled: True
          (optional) cacert: cert body if the cacert_file does not exists
          (optional) cacert_file: /etc/openstack/rabbitmq-ca.pem
          (optional) version: TLSv1_2


- **MySQL TLS**

.. code-block:: yaml

 cinder:
   controller:
      database:
        ssl:
          enabled: True
          (optional) cacert: cert body if the cacert_file does not exists
          (optional) cacert_file: /etc/openstack/mysql-ca.pem

- **Openstack HTTPS API**

.. code-block:: yaml

 cinder:
  controller, volume:
      identity:
         protocol: https
         (optional) cacert_file: /etc/openstack/proxy.pem
      glance:
         protocol: https
         (optional) cacert_file: /etc/openstack/proxy.pem



Cinder setup with zeroing deleted volumes

.. code-block:: yaml

    cinder:
      controller:
        enabled: true
        wipe_method: zero
        ...

Cinder setup with shreding deleted volumes

.. code-block:: yaml

    cinder:
      controller:
        enabled: true
        wipe_method: shred
        ...

Configuration of policy.json file

.. code-block:: yaml

    cinder:
      controller:
        ....
        policy:
          'volume:delete': 'rule:admin_or_owner'
          # Add key without value to remove line from policy.json
          'volume:extend':

Default Cinder backend lvm_type setup

.. code-block:: yaml

    cinder:
      volume:
        enabled: true
        backend:
          # Type of LVM volumes to deploy; (default, thin, or auto). Auto defaults to thin if thin is supported.
          lvm_type: auto


Default Cinder setup with iSCSI target

.. code-block:: yaml

    cinder:
      controller:
        enabled: true
        version: mitaka
        default_volume_type: lvmdriver-1
        database:
          engine: mysql
          host: 127.0.0.1
          port: 3306
          name: cinder
          user: cinder
          password: pwd
        identity:
          engine: keystone
          host: 127.0.0.1
          port: 35357
          tenant: service
          user: cinder
          password: pwd
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        backend:
          lvmdriver-1:
            engine: lvm
            type_name: lvmdriver-1
            volume_group: cinder-volume

Cinder setup for IBM Storwize

.. code-block:: yaml

    cinder:
      volume:
        enabled: true
        backend:
          7k2_SAS:
            engine: storwize
            type_name: 7k2 SAS disk
            host: 192.168.0.1
            port: 22
            user: username
            password: pass
            connection: FC/iSCSI
            multihost: true
            multipath: true
            pool: SAS7K2
          10k_SAS:
            engine: storwize
            type_name: 10k SAS disk
            host: 192.168.0.1
            port: 22
            user: username
            password: pass
            connection: FC/iSCSI
            multihost: true
            multipath: true
            pool: SAS10K
          15k_SAS:
            engine: storwize
            type_name: 15k SAS
            host: 192.168.0.1
            port: 22
            user: username
            password: pass
            connection: FC/iSCSI
            multihost: true
            multipath: true
            pool: SAS15K


Cinder setup with NFS

.. code-block:: yaml

    cinder:
      controller:
        enabled: true
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


Cinder setup with NetApp

.. code-block:: yaml

    cinder:
      controller:
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
            lun_space_reservation: enabled
            use_multipath_for_image_xfer: True
            nas_secure_file_operations: false
            nas_secure_file_permissions: false
            devices:
              - 172.18.1.2:/vol_1
              - 172.18.1.2:/vol_2
              - 172.18.1.2:/vol_3
              - 172.18.1.2:/vol_4
    linux:
      system:
        package:
          nfs-common:
            version: latest


Cinder setup with Hitachi VPS

.. code-block:: yaml

    cinder:
      controller:
        enabled: true
        backend:
          hus100_backend:
            type_name: HUS100
            backend: hus100_backend
            engine: hitachi_vsp
            connection: FC

Cinder setup with Hitachi VPS with defined ldev range

.. code-block:: yaml

    cinder:
      controller:
        enabled: true
        backend:
          hus100_backend:
            type_name: HUS100
            backend: hus100_backend
            engine: hitachi_vsp
            connection: FC
            ldev_range: 0-1000

Cinder setup with CEPH

.. code-block:: yaml

    cinder:
      controller:
        enabled: true
        backend:
          ceph_backend:
            type_name: standard-iops
            backend: ceph_backend
            pool: volumes
            engine: ceph
            user: cinder
            secret_uuid: da74ccb7-aa59-1721-a172-0006b1aa4e3e
            client_cinder_key: AQDOavlU6BsSJhAAnpFR906mvdgdfRqLHwu0Uw==
            report_discard_supported: True

http://ceph.com/docs/master/rbd/rbd-openstack/


Cinder setup with HP3par

.. code-block:: yaml

    cinder:
      controller:
        enabled: true
        backend:
          hp3par_backend:
            type_name: hp3par
            backend: hp3par_backend
            user: hp3paruser
            password: something
            url: http://10.10.10.10/api/v1
            cpg: OpenStackCPG
            host: 10.10.10.10
            login: hp3paradmin
            sanpassword: something
            debug: True
            snapcpg: OpenStackSNAPCPG

Cinder setup with Fujitsu Eternus

.. code-block:: yaml

    cinder:
      volume:
        enabled: true
        backend:
          10kThinPro:
            type_name: 10kThinPro
            engine: fujitsu
            pool: 10kThinPro
            host: 192.168.0.1
            port: 5988
            user: username
            password: pass
            connection: FC/iSCSI
            name: 10kThinPro
          10k_SAS:
            type_name: 10k_SAS
            pool: SAS10K
            engine: fujitsu
            host: 192.168.0.1
            port: 5988
            user: username
            password: pass
            connection: FC/iSCSI
            name: 10k_SAS

Cinder setup with IBM GPFS filesystem

.. code-block:: yaml

    cinder:
      volume:
        enabled: true
        backend:
          GPFS-GOLD:
            type_name: GPFS-GOLD
            engine: gpfs
            mount_point: '/mnt/gpfs-openstack/cinder/gold'
          GPFS-SILVER:
            type_name: GPFS-SILVER
            engine: gpfs
            mount_point: '/mnt/gpfs-openstack/cinder/silver'

Cinder setup with HP LeftHand

.. code-block:: yaml

    cinder:
      volume:
        enabled: true
        backend:
          HP-LeftHand:
            type_name: normal-storage
            engine: hp_lefthand
            api_url: 'https://10.10.10.10:8081/lhos'
            username: user
            password: password
            clustername: cluster1
            iscsi_chap_enabled: false

Extra parameters for HP LeftHand

.. code-block:: yaml

    cinder type-key normal-storage set hplh:data_pl=r-10-2 hplh:provisioning=full

Cinder setup with Solidfire

.. code-block:: yaml

    cinder:
      volume:
        enabled: true
        backend:
          solidfire:
            type_name: normal-storage
            engine: solidfire
            san_ip: 10.10.10.10
            san_login: user
            san_password: password
            clustername: cluster1
            sf_emulate_512: false
            sf_api_port: 14443
            host: ctl01

Cinder setup with Block Device driver

.. code-block:: yaml

    cinder:
      volume:
        enabled: true
        backend:
          bdd:
            engine: bdd
            enabled: true
            type_name: bdd
            devices:
              - sdb
              - sdc
              - sdd

Enable cinder-backup service for ceph

.. code-block:: yaml

    cinder:
      controller:
        enabled: true
        version: mitaka
        backup:
          engine: ceph
          ceph_conf: "/etc/ceph/ceph.conf"
          ceph_pool: backup
          ceph_stripe_count: 0
          ceph_stripe_unit: 0
          ceph_user: cinder
          ceph_chunk_size: 134217728
          restore_discard_excess_bytes: false
      volume:
        enabled: true
        version: mitaka
        backup:
          engine: ceph
          ceph_conf: "/etc/ceph/ceph.conf"
          ceph_pool: backup
          ceph_stripe_count: 0
          ceph_stripe_unit: 0
          ceph_user: cinder
          ceph_chunk_size: 134217728
          restore_discard_excess_bytes: false

Enable auditing filter, ie: CADF

.. code-block:: yaml

    cinder:
      controller:
        audit:
          enabled: true
      ....
          filter_factory: 'keystonemiddleware.audit:filter_factory'
          map_file: '/etc/pycadf/cinder_api_audit_map.conf'
      ....
      volume:
        audit:
          enabled: true
      ....
          filter_factory: 'keystonemiddleware.audit:filter_factory'
          map_file: '/etc/pycadf/cinder_api_audit_map.conf'


Cinder setup with custom availability zones:

.. code-block:: yaml

    cinder:
      controller:
        default_availability_zone: my-default-zone
        storage_availability_zone: my-custom-zone-name
    cinder:
      volume:
        default_availability_zone: my-default-zone
        storage_availability_zone: my-custom-zone-name


Cinder setup with custom non-admin volume query filters:

.. code-block:: yaml

    cinder:
      controller:
        query_volume_filters:
          - name
          - status
          - metadata
          - availability_zone
          - bootable


public_endpoint and osapi_volume_base_url parameters:
"public_endpoint" is used for configuring versions endpoint,
"osapi_volume_base_URL" is used to present Cinder URL to users.
They are useful when running Cinder under load balancer in SSL.

.. code-block:: yaml

    cinder:
      controller:
        public_endpoint_address: https://${_param:cluster_domain}:8776

The default availability zone is used when a volume has been created, without specifying a zone in the create request. (this zone must exist in your configuration obviously)
The storage availability zone is the actual zone where the node belongs to. Make sure to specify this per node.
Check the documentation of OpenStack for more information


Client role

.. code-block:: yaml

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

Enable Barbican integration

.. code-block:: yaml

    cinder:
      controller:
        barbican:
          enabled: true


Specify Keystone API version (v3 is default):

.. code-block:: yaml

    cinder:
      controller:
        identity:
          api_version: v2.0

Enhanced logging with logging.conf
----------------------------------

By default logging.conf is disabled.

That is possible to enable per-binary logging.conf with new variables:
  * openstack_log_appender - set it to true to enable log_config_append for all OpenStack services;
  * openstack_fluentd_handler_enabled - set to true to enable FluentHandler for all Openstack services.
  * openstack_ossyslog_handler_enabled - set to true to enable OSSysLogHandler for all Openstack services.

Only WatchedFileHandler, OSSysLogHandler and FluentHandler are available.

Also it is possible to configure this with pillar:

.. code-block:: yaml

  cinder:
    controller:
      logging:
        log_appender: true
        log_handlers:
          watchedfile:
            enabled: true
          fluentd:
            enabled: true
          ossyslog:
            enabled: true

    volume:
      logging:
        log_appender: true
        log_handlers:
          watchedfile:
            enabled: true
          fluentd:
            enabled: true
          ossyslog:
            enabled: true

Documentation and Bugs
============================

To learn how to deploy OpenStack Salt, consult the documentation available
online at:

https://wiki.openstack.org/wiki/OpenStackSalt

In the unfortunate event that bugs are discovered, they should be reported to
the appropriate bug tracker. If you obtained the software from a 3rd party
operating system vendor, it is often wise to use their own bug tracker for
reporting problems. In all other cases use the master OpenStack bug tracker,
available at:

    http://bugs.launchpad.net/openstack-salt

Developers wishing to work on the OpenStack Salt project should always base
their work on the latest formulas code, available from the master GIT
repository at:

    https://git.openstack.org/cgit/openstack/salt-formula-cinder

Developers should also join the discussion on the IRC list, at:

    https://wiki.openstack.org/wiki/Meetings/openstack-salt

Documentation and Bugs
======================

To learn how to install and update salt-formulas, consult the documentation
available online at:

    http://salt-formulas.readthedocs.io/

In the unfortunate event that bugs are discovered, they should be reported to
the appropriate issue tracker. Use Github issue tracker for specific salt
formula:

    https://github.com/salt-formulas/salt-formula-cinder/issues

For feature requests, bug reports or blueprints affecting entire ecosystem,
use Launchpad salt-formulas project:

    https://launchpad.net/salt-formulas

You can also join salt-formulas-users team and subscribe to mailing list:

    https://launchpad.net/~salt-formulas-users

Developers wishing to work on the salt-formulas projects should always base
their work on master branch and submit pull request against specific formula.

    https://github.com/salt-formulas/salt-formula-cinder

Any questions or feedback is always welcome so feel free to join our IRC
channel:

    #salt-formulas @ irc.freenode.net
