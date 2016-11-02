/etc/yum.repos.d/docker.repo:
  file.managed:
    - contents: |
        [dockerrepo]
        name=Docker Repository
        baseurl=https://yum.dockerproject.org/repo/main/centos/7/
        enabled=1
        gpgcheck=1
        gpgkey=https://yum.dockerproject.org/gpg

docker-engine:
  pkg.installed:
    - require:
      - file: /etc/yum.repos.d/docker.repo
    - watch_in:
      - cmd: daemon-reload
  service.running:
    - name: docker
    - enable: True
    - watch:
      - pkg: docker-engine

daemon-reload:
  cmd.wait:
    - name: |
        systemctl daemon-reload

{% for disk in ["b", "c", "d"] %}
disk-{{disk}}:
  cmd.run:
    - name: |
        mkdir -p /mnt/disk-{{disk}}
        mkfs.xfs /dev/sd{{disk}}
        tee -a /etc/fstab <<-DISK
        /dev/sd${disk} /mnt/disk-{{disk}} xfs rw,relatime,attr2,inode64,noquota 0 0
        DISK
        mount /mnt/disk-{{disk}}
    - unless: |
        [ -d "/mnt/disk-{{disk}}" ]
{% endfor %}

java-1.8.0-openjdk: pkg.installed
net-tools: pkg.installed

/usr/local/zookeeper-3.4.9.tar.gz:
  file.managed:
    - source: http://apache.cs.utah.edu/zookeeper/zookeeper-3.4.9/zookeeper-3.4.9.tar.gz
    - source_hash: md5=3e8506075212c2d41030d874fcc9dcd2
  cmd.run:
    - name: |
        tar xzf /usr/local/zookeeper-3.4.9.tar.gz -C /usr/local
        ln -sf /usr/local/zookeeper-3.4.9 /usr/local/zookeeper
    - require:
      - file: /usr/local/zookeeper-3.4.9.tar.gz
    - unless: |
        [ -d /usr/local/zookeeper ]


/etc/systemd/system/zookeeper.service:
  file.managed:
    - contents: |
        [Unit]
        Description=Apache Zookeeper
        After=network.target

        [Service]
        User=root
        SyslogIdentifier=zookeeper
        EnvironmentFile=/etc/zookeeper/conf/zookeeper.env
        ExecStart=/bin/bash -x /usr/local/zookeeper/bin/zkServer.sh start-foreground

        [Install]
        WantedBy=multi-user.target
    - require:
      - file: /usr/local/zookeeper-3.4.9.tar.gz
      - cmd: /usr/local/zookeeper-3.4.9.tar.gz
    - watch_in:
      - cmd: daemon-reload

/etc/zookeeper/conf: file.directory
/var/run/zookeeper: file.directory
/var/log/zookeeper: file.directory

zookeeper:
  service.running:
    - enable: True
    - require:
      - cmd: daemon-reload
      - file: /etc/systemd/system/zookeeper.service
      - cmd: /usr/local/zookeeper-3.4.9.tar.gz
      - file: /etc/zookeeper/conf
      - file: /var/run/zookeeper
      - file: /var/log/zookeeper
    - watch:
      - file: /etc/zookeeper/conf/zookeeper.env

/etc/zookeeper/conf/zookeeper.env:
  file.managed:
    - contents: |
        ZOO_LOG4J_PROP=DEBUG,ROLLINGFILE
        ZOO_LOG_DIR=/var/log/zookeeper
        ZOOPIDFILE=/var/run/zookeeper/zookeeper-server.pid
        SERVER_JVMFLAGS="-Xms256m -Xmx256m -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=127.0.0.1 -Dcom.sun.management.jmxremote.port=1098"
    - require:
      - file: /etc/zookeeper/conf

/usr/local/zookeeper/conf/zoo.cfg:
  file.managed:
    - require:
      - cmd: /usr/local/zookeeper-3.4.9.tar.gz
    - contents: |
        tickTime=2000
        dataDir=/var/lib/zookeeper
        clientPort=2181

jq: pkg.installed

