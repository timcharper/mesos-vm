include:
  - .systemd

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
