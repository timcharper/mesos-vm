include:
  - .jq

yum-plugin-priorities: pkg.installed

centos-release-ceph-jewel: pkg.installed

ceph:
  pkg.installed:
    - require:
      - pkg: centos-release-ceph-jewel

/etc/ceph/ceph.conf:
  cmd.run:
    - require:
      - pkg: ceph
    - name: |
cat <<-EOF > /etc/ceph/ceph.conf
[global]
fsid = {{pillar.ceph.fsid}}
mon host = $(curl localhost:8123/v1/services/_mon._tcp.ceph.mesos | jq '. | map(.ip + ":" + .port) | sort | join(",")')

auth cluster required = cephx
auth service required = cephx
auth client required = cephx
public network = 192.168.33.0/24
cluster network = 192.168.33.0/24
max_open_files = 131072
mon_osd_full_ratio = ".95"
mon_osd_nearfull_ratio = ".85"
osd_pool_default_min_size = 1
osd_pool_default_pg_num = 128
osd_pool_default_pgp_num = 128
osd_pool_default_size = 3
rbd_default_features = 1
EOF
    - unless: |
        [ -f /etc/ceph/ceph.conf ]

/etc/ceph/ceph.mon.keyring:
  file.managed:
    - require:
      - pkg: ceph
    - contents: |
        [mon.]
          key = {{pillar.ceph.mon_keyring}}
          caps mon = "allow *"

/etc/ceph/ceph.client.admin.keyring:
  file.managed:
    - require:
      - pkg: ceph
    - contents: |
        [client.admin]
          key = {{pillar.ceph.client_admin_keyring}}
          auid = 0
          caps mds = "allow"
          caps mon = "allow *"
          caps osd = "allow *"

/etc/ceph/monmap-ceph:
  cmd.run:
    - name: ceph mon getmap -o /etc/ceph/monmap-ceph
    - require:
      - file: /etc/ceph/ceph.client.admin.keyring
      - file: /etc/ceph/ceph.mon.keyring
      - cmd: /etc/ceph/ceph.conf
      - pkg: ceph
    - unless: |
        [ -f /etc/ceph/monmap-ceph ]
