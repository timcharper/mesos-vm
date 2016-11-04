include:
  - setup.systemd
  - setup.java

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

/etc/zookeeper/conf:
  file.directory:
    - makedirs: True
/var/run/zookeeper: file.directory
/var/log/zookeeper: file.directory

/usr/local/bin/zkCli:
  file.managed:
    - contents: |
        exec /usr/local/zookeeper/bin/zkCli.sh
    - mode: 755

zookeeper:
  service.running:
    - enable: True
    - require:
      - cmd: daemon-reload
      - pkg: java
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
