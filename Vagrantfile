# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

Vagrant.configure("2") do |top|
  [1,2,3].each do |mesos_id|
    def ip_for(id)
      "192.168.33.#{9 + id}"
    end
    master_ip = ip_for(1)

    top.vm.define "mesos-#{mesos_id}" do |node|
      ip = ip_for(mesos_id)
      # The most common configuration options are documented and commented below.
      # For a complete reference, please see the online documentation at
      # https://docs.vagrantup.com.

      # Every Vagrant development environment requires a box. You can search for
      # boxes at https://atlas.hashicorp.com/search.
      node.vm.box = "https://github.com/CommanderK5/packer-centos-template/releases/download/0.7.2/vagrant-centos-7.2.box"

      # Disable automatic box update checking. If you disable this, then
      # boxes will only be checked for updates when the user runs
      # `vagrant box outdated`. This is not recommended.
      node.vm.box_check_update = false

      # Create a forwarded port mapping which allows access to a specific port
      # within the machine from a port on the host machine. In the example below,
      # accessing "localhost:8080" will access port 80 on the guest machine.
      # node.vm.network "forwarded_port", guest: 80, host: 8080

      # Create a private network, which allows host-only access to the machine
      # using a specific IP.
      node.vm.network "private_network", ip: ip, :auto_config => false

      # Create a public network, which generally matched to bridged network.
      # Bridged networks make the machine appear as another physical device on
      # your network.
      # node.vm.network "public_network"

      # Share an additional folder to the guest VM. The first argument is
      # the path on the host to the actual folder. The second argument is
      # the path on the guest to mount the folder. And the optional third
      # argument is a set of non-required options.
      node.vm.synced_folder "srv/", "/srv"

      # Provider-specific configuration so you can fine-tune various
      # backing providers for Vagrant. These expose provider-specific options.
      # Example for VirtualBox:
      #
      
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
        vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
        # Display the VirtualBox GUI when booting the machine
        # vb.gui = true
        
        # Customize the amount of memory on the VM:
        vb.memory = "1024"
        for n in [1, 2]
          file_to_disk = File.realpath( "." ).to_s + "/mesos-#{mesos_id}-disk-#{n}.vdi"

          if ! File.exist?(file_to_disk)
            vb.customize ['createhd',
                          '--filename', file_to_disk,
                          '--format', 'VDI',
                          '--size', 1024 # 1 GB
                         ]
            vb.customize ['storageattach', :id,
                          '--storagectl', 'SATA Controller', # The name may vary
                          '--port', n, '--device', 0,
                          '--type', 'hdd', '--medium',
                          file_to_disk
                         ]
          end
        end
      end
    
      #
      # View the documentation for the provider you are using for more
      # information on available options.

      # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
      # such as FTP and Heroku are also available. See the documentation at
      # https://docs.vagrantup.com/v2/push/atlas.html for more information.
      # node.push.define "atlas" do |push|
      #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
      # end

      # Enable provisioning with a shell script. Additional provisioners such as
      # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
      # documentation for more information about their specific syntax and use.
      node.vm.provision "shell", inline: <<-SHELL
        sudo tee /etc/sysconfig/network-scripts/ifcfg-eth1 <<-ETH1
NM_CONTROLLED=no
BOOTPROTO=none
ONBOOT=yes
IPADDR=#{ip}
NETMASK=255.255.255.0
DEVICE=eth1
PEERDNS=no
ETH1
        rm -f /etc/sysconfig/network-scripts/ifcfg-enp0s3
        service network restart

        sudo tee -a /etc/hosts <<-HOSTS
#{ip_for 1} mesos-1.dev.vagrant
#{ip_for 2} mesos-2.dev.vagrant
#{ip_for 3} mesos-3.dev.vagrant
HOSTS

        curl -o bootstrap_salt.sh -L https://bootstrap.saltstack.com
        sudo sh bootstrap_salt.sh #{mesos_id == 1 ? " -M" : ""} git v2015.8.10
        sudo mkdir -p /etc/salt
        sudo tee /etc/salt/minion <<-SALT
master: #{master_ip}
hash_type: sha256
SALT
        sudo tee /etc/salt/minion_id <<-SALT
mesos-#{mesos_id}.dev.vagrant
SALT
      SHELL
    end
  end
end
