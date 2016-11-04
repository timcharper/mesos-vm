{% for disk in ["b", "c"] %}
disk-{{disk}}:
  cmd.run:
    - name: |
        mkdir -p /mnt/disk-{{disk}}
        mkfs.xfs /dev/sd{{disk}}
        tee -a /etc/fstab <<-DISK
        /dev/sd{{disk}} /mnt/disk-{{disk}} xfs rw,relatime,attr2,inode64,noquota 0 0
        DISK
        mount /mnt/disk-{{disk}}
    - unless: |
        [ -d "/mnt/disk-{{disk}}" ]
{% endfor %}

