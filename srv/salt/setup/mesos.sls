include:
  - setup.systemd
  - .cacert

mesosphere-el-repo:
  pkg.installed:
    - sources:
      - mesosphere-el-repo: http://repos.mesosphere.com/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm
mesos:
  pkg.installed:
    - version: 1.2.0-2.0.6
    - require:
      - pkg: mesosphere-el-repo

/etc/pki/tls/certs/mesos.dev.vagrant.crt:
  file.managed:
    - contents_pillar: mesos:mesos.dev.vagrant.crt
    - mode: 664

/etc/pki/tls/private/mesos.dev.vagrant.key:
  file.managed:
    - contents_pillar: mesos:mesos.dev.vagrant.key
    - mode: 600

/etc/mesos/zk:
  file.managed:
    - contents: zk://192.168.33.10:2181/mesos

/etc/mesos/.slave-credentials:
  file.managed:
    - mode: 600
    - contents: |
        {
          "principal": "mesos-slave",
          "secret": "very-dev"
        }
    - watch_in:
      - service: mesos-slave
        
{% set slave = {
  "credential": "/etc/mesos/.slave-credentials",
  "resources": [
    {
      "name": "cpus",
      "type": "SCALAR",
      "scalar": {
        "value": 2
      }
    },
    {
      "name": "mem",
      "type": "SCALAR",
      "scalar": {
        "value": 3096
      }
    },
    {
      "name": "disk",
      "type": "SCALAR",
      "scalar": {
        "value": 4096
      }
    },
    {
      "name": "disk",
      "type": "SCALAR",
      "scalar": {
        "value": 1024
      },
      "disk" : {
        "source" : {
          "type" : "MOUNT",
          "mount" : { "root" : "/mnt/disk-b" }
        }
      }
    },
    {
      "name": "disk",
      "type": "SCALAR",
      "scalar": {
        "value": 1024
      },
      "disk" : {
        "source" : {
          "type" : "MOUNT",
          "mount" : { "root" : "/mnt/disk-c" }
        }
      }
    }
  ] | json,
  "ip": grains['ip4_interfaces']['enp0s8'][0],
  "hostname": grains.id,
  "switch_user": "false",
  "containerizers": "mesos,docker",
  "image_providers": "APPC,DOCKER",
  "isolation": "cgroups/cpu,cgroups/mem,docker/runtime,filesystem/linux",
  "executor_environment_variables": {
    "LIBPROCESS_SSL_KEY_FILE": "/etc/pki/tls/private/mesos.dev.vagrant.key",
    "LIBPROCESS_SSL_CERT_FILE": "/etc/pki/tls/certs/mesos.dev.vagrant.crt",
    "LIBPROCESS_SSL_CA_FILE": "/etc/pki/ca-trust/source/anchors/dev-root-ca.crt",
    "LIBPROCESS_SSL_ENABLED": "true",
    "LIBPROCESS_SSL_SUPPORT_DOWNGRADE": "true"
  } | json,
  "network_cni_config_dir": "/usr/libexec/cni/config",
  "network_cni_plugins_dir": "/usr/libexec/cni/bin"
} %}

{% for key, value in slave.items() %}
/etc/mesos-slave/{{key}}:
  file.managed:
    - contents: |
        {{value}}
    - watch_in:
      - service: mesos-slave
    - require:
      - pkg: mesos
{% endfor %}

/etc/default/mesos-slave:
  file.managed:
    - contents: |
        MASTER=`cat /etc/mesos/zk`
        LIBPROCESS_SSL_KEY_FILE=/etc/pki/tls/private/mesos.dev.vagrant.key
        LIBPROCESS_SSL_CERT_FILE=/etc/pki/tls/certs/mesos.dev.vagrant.crt
        LIBPROCESS_SSL_CA_FILE=/etc/pki/ca-trust/source/anchors/dev-root-ca.crt
        LIBPROCESS_SSL_ENABLED=true
        LIBPROCESS_SSL_SUPPORT_DOWNGRADE=true

mesos-slave:
  service.running:
    - require:
      - pkg: mesos
      - cmd: update-ca-trust
    - watch:
      - file: /etc/default/mesos-slave
      - file: /etc/pki/tls/private/mesos.dev.vagrant.key
      - file: /etc/pki/tls/certs/mesos.dev.vagrant.crt
        

/etc/mesos/.credentials:
  file.managed:
    - require:
      - pkg: mesos
    - watch_in:
      - service: mesos-master
    - contents: |
        {
          "credentials": [
            {
              "principal": "ceph",
              "secret": "very-ceph"
            },{
              "principal": "marathon",
              "secret": "very-marathon"
            },{
              "principal": "dcos_marathon",
              "secret": "very-marathon"
            },
            {
              "principal": "mesos-slave",
              "secret": "very-dev"
            }
          ]
        }
{% set master = {
  "ip": grains['ip4_interfaces']['enp0s8'][0],
  "hostname": grains.id,
  "authenticate_slaves": "true",
  "authenticate": "true",
  "credentials": "/etc/mesos/.credentials"
} %}

{% for key, value in master.items() %}
/etc/mesos-master/{{key}}:
  file.managed:
    - contents: |
        {{value}}
    - watch_in:
      - service: mesos-master
    - require:
      - pkg: mesos
{% endfor %}

/etc/default/mesos-master:
  file.managed:
    - contents: |
        PORT=5050
        ZK=`cat /etc/mesos/zk`
        LIBPROCESS_SSL_KEY_FILE=/etc/pki/tls/private/mesos.dev.vagrant.key
        LIBPROCESS_SSL_CERT_FILE=/etc/pki/tls/certs/mesos.dev.vagrant.crt
        LIBPROCESS_SSL_CA_FILE=/etc/pki/ca-trust/source/anchors/dev-root-ca.crt
        LIBPROCESS_SSL_ENABLED=true
        LIBPROCESS_SSL_SUPPORT_DOWNGRADE=true

mesos-master:
  service.running:
    - require:
      - pkg: mesos
      - cmd: update-ca-trust
    - watch:
      - file: /etc/default/mesos-master
      - file: /etc/pki/tls/private/mesos.dev.vagrant.key
      - file: /etc/pki/tls/certs/mesos.dev.vagrant.crt

/usr/bin/mesos-dns:
  file.managed:
    - source: https://github.com/mesosphere/mesos-dns/releases/download/v0.6.0/mesos-dns-v0.6.0-linux-amd64
    - source_hash: md5=a00f1e3381e0cb3b092eefc1bf81ea98
    - mode: 755
/etc/mesos-dns.conf:
  file.managed:
    - contents: |
        {
          "zk": "zk://mesos-1.dev.vagrant:2181/mesos",
          "masters": ["mesos-1.dev.vagrant:5050", "mesos-2.dev.vagrant:5050", "mesos-3.dev.vagrant:5050"],
          "refreshSeconds": 60,
          "ttl": 60,
          "domain": "mesos",
          "port": 53,
          "resolvers": ["8.8.8.8", "8.8.4.4"],
          "timeout": 5, 
          "httpon": true,
          "dnson": true,
          "httpport": 8123,
          "externalon": true,
          "listener": "{{grains['ip4_interfaces']['enp0s8'][0]}}",
          "httpListener": "{{grains['ip4_interfaces']['enp0s8'][0]}}",
          "SOAMname": "ns1.mesos",
          "SOARname": "root.ns1.mesos",
          "SOARefresh": 60,
          "SOARetry":   600,
          "SOAExpire":  86400,
          "SOAMinttl": 60,
          "IPSources": ["netinfo", "mesos", "host"]
        }

/etc/systemd/system/mesos-dns.service:
  file.managed:
    - contents: |
        [Unit]
        Description=Mesos DNS
        After=network.target

        [Service]
        User=root
        ExecStart=/usr/bin/mesos-dns -config /etc/mesos-dns.conf -v 1

        [Install]
        WantedBy=multi-user.target
    - require:
      - file: /usr/bin/mesos-dns
    - watch_in:
      - cmd: daemon-reload

mesos-dns:
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/mesos-dns.service
      - file: /etc/mesos-dns.conf
      - file: /usr/bin/mesos-dns
    - require:
      - cmd: daemon-reload

/etc/NetworkManager/conf.d/no-dns.conf:
  file.managed:
    - contents: |
        [main]
        dns=none
/etc/resolv.conf:
  file.managed:
    - contents: |
        search dev.vagrant
        nameserver {{grains['ip4_interfaces']['enp0s8'][0]}}
