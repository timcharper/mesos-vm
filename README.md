# Mesos VM

Vagrant configuration which can be used to create a 3 node mesos cluster.

## Steps

### 1) Generate certs

```
cd ssl/
make
# I don't know why you need to run it twice right now, but you do.
make
```

If you like, you can import ssl/root-ca/cacert.pem into your trusted cert chain. By default the certificate is valid for 90 days. If you do this... keep it secret !!!

### 2) Vagrant up

```
vagrant up
```

This should install saltstack and provision the disks. It history is a reliable way to predict the future, then you will probably need to diagnose and resolve an issue or two. Good luck!

### 3) Apply high state

```
vagrant ssh mesos-1
sudo su - 
salt-key -A

# confirm that the minions are connected
salt '*' test.ping

# they are? great! install all the things.
salt '*' state.highstate
```

(didn't succeed first time? Try and apply highstate again.)

Add host entries

```
sudo tee -a /etc/hosts <<-HOSTS
192.168.33.10 mesos-1.dev.vagrant
192.168.33.11 mesos-2.dev.vagrant
192.168.33.12 mesos-3.dev.vagrant
HOSTS
```

### 4) Check configuration

open http://192.168.33.10:5050

Click agents tab and see if the mesos slaves / agents have registered.

These commands will will help you figure if things aren't working:

```
journalctl -xefu mesos-slave

ping leader.mesos # return IP address of current master

# (on the vm currently running the master)

journalctl -xefu mesos-master

```
