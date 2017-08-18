/usr/libexec/cni:
  file.directory

/usr/libexec/cni/config:
  file.directory:
    - require:
      - file: /usr/libexec/cni

/usr/libexec/cni/bin:
  file.directory:
    - require:
      - file: /usr/libexec/cni

/usr/libexec/cni/config/demo.json:
  file.managed:
    - require:
      - file: /usr/libexec/cni/config
    - contents: |
        {
          "cniVersion": "0.3.1",
          "name": "demo",
          "type": "demo",
          "plugins": [
            {
              "type": "bridge",
              "bridge": "cni0",
              "args": {
                "labels" : {
                  "appVersion" : "1.0"
                }
              },
              "ipam": {
                "type": "host-local",
                "subnet": "10.1.0.0/16",
                "gateway": "10.1.0.1"
              },
              "dns": {
                "nameservers": [ "10.1.0.1" ]
              }
            },
            {
              "type": "tuning",
              "sysctl": {
                "net.core.somaxconn": "500"
              }
            }
          ]
        }
/usr/libexec/cni/bin/demo:
  file.managed:
    - mode: 755
    - require:
      - file: /usr/libexec/cni/config
    - contents: |
        date >> /tmp/cni-demo-debug
        set >> /tmp/cni-demo-debug
        echo "==================================" >> /tmp/cni-demo-debug
        cat <<-EOF
        {
          "cniVersion": "0.3.1",
          "code": 15,
          "msg": "failed",
          "details": "Things went terribly wrong"
        }
        EOF
        exit 1
