bash-completion:
  pkg.installed

/usr/local/bin/mesos-cli:
  file.managed:
    - source: salt://{{tpldir}}/mcli/mesos-cli
    - mode: 755

/usr/local/bin/dicker:
  file.managed:
    - source: salt://{{tpldir}}/mcli/dicker
    - mode: 755

/usr/local/etc/bash_completion.d:
  file.directory


{% for f in ["mesos-cli-completion", "dicker-completion"] %}

/usr/local/etc/bash_completion.d/{{f}}:
  file.managed:
    - source: salt://{{tpldir}}/mcli/{{f}}
    - mode: 644
    - require:
      - file: /usr/local/etc/bash_completion.d

/etc/bash_completion.d/{{f}}:
  file.symlink:
    - target: /usr/local/etc/bash_completion.d/{{f}}
    - require:
      - file: /usr/local/etc/bash_completion.d/{{f}}
      - pkg: bash-completion

{% endfor %}
