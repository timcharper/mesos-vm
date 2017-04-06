base:
  'mesos-1.dev.vagrant':
    - setup.zookeeper
  '*':
    - setup.docker
    - setup.mesos
    - setup.network
    - setup.cacert
    - setup.jq
    - setup.mcli
    - setup.java
    - setup.disks
    - setup.general
