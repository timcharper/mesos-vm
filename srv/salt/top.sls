base:
  'mesos-1.dev.vagrant':
    - setup.zookeeper
  '*':
    - setup.docker
    - setup.mesos
    - setup.network
    - setup.cacert
    - setup.jq
    - setup.java
    - setup.disks
    - setup.general
