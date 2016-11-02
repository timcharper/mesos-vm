/etc/pki/ca-trust/source/anchors/dev-root-ca.crt:
  file.managed:
    - contents_pillar: cacert.crt
    - mode: 644
    - watch_in:
      - cmd: update-ca-trust
update-ca-trust:
  cmd.wait:
    - name: "update-ca-trust extract"
