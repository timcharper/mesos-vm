include:
  - .jq
net-tools: pkg.installed
nmap-ncat: pkg.installed
bind-utils: pkg.installed
vim-enhanced: pkg.installed
ntp:
  pkg:
    - installed
  service.running:
    - name: ntpd
    - enable: True
    - require:
      - pkg: ntp


