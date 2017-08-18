{% set version = "v0.2"%}

bash-completion:
  pkg.installed

/usr/local/bin/mesos-cli:
  file.managed:
    - source: https://raw.githubusercontent.com/timcharper/mcli/{{version}}/mesos-cli
    - source_hash: sha256=f0895ab2fcd5326c4a8f4c69f77762fdaba5399136c3aff608460116e5d5c1e0
    - mode: 755

/usr/local/bin/dicker:
  file.managed:
    - source: https://raw.githubusercontent.com/timcharper/mcli/{{version}}/dicker
    - source_hash: sha256=b7ea20affd0856383347c4460e979fd3d5a801e234ebb3dab5406ffbed8bbce7
    - mode: 755

/usr/local/etc/bash_completion.d:
  file.directory


/usr/local/etc/bash_completion.d/mesos-cli-completion:
  file.managed:
    - source: https://raw.githubusercontent.com/timcharper/mcli/{{version}}/mesos-cli-completion
    - source_hash: sha256=be37749f670ef265eb5c081cb9b08e0bf6ea867153804e779472346bd02f8c9a
    - mode: 644
    - require:
      - file: /usr/local/etc/bash_completion.d

/etc/bash_completion.d/mesos-cli-completion:
  file.symlink:
    - target: /usr/local/etc/bash_completion.d/mesos-cli-completion
    - require:
      - file: /usr/local/etc/bash_completion.d/mesos-cli-completion
      - pkg: bash-completion

/usr/local/etc/bash_completion.d/dicker-completion:
  file.managed:
    - source: salt://{{tpldir}}/mcli/dicker-completion
    - mode: 644
    - require:
      - file: /usr/local/etc/bash_completion.d

/etc/bash_completion.d/dicker-completion:
  file.symlink:
    - target: /usr/local/etc/bash_completion.d/dicker-completion
    - require:
      - file: /usr/local/etc/bash_completion.d/dicker-completion
      - pkg: bash-completion
