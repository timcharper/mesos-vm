include:
  - .cacert

mesosphere-el-repo:
  pkg.installed:
    - sources:
      - mesosphere-el-repo: http://repos.mesosphere.com/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm
mesos:
  pkg.installed:
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

/etc/mesos/.slave-credentials:
  file.managed:
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
          "mount" : { "root" : "/mnt/disk-d" }
        }
      }
    }
  ] | json,
  "ip": "192.168.33.10",
  "hostname": "192.168.33.10",
  "switch_user": "false",
  "containerizers": "mesos,docker"
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
        LIBPROCESS_SSL_ENABLED=true
        LIBPROCESS_SSL_SUPPORT_DOWNGRADE=false

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
            },
            {
              "principal": "mesos-slave",
              "secret": "very-dev"
            }
          ]
        }
{% set master = {
  "ip": "192.168.33.10",
  "hostname": "192.168.33.10",
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
        LIBPROCESS_SSL_ENABLED=true
        LIBPROCESS_SSL_SUPPORT_DOWNGRADE=false

mesos-master:
  service.running:
    - require:
      - pkg: mesos
      - cmd: update-ca-trust
    - watch:
      - file: /etc/default/mesos-master
      - file: /etc/pki/tls/private/mesos.dev.vagrant.key
      - file: /etc/pki/tls/certs/mesos.dev.vagrant.crt
