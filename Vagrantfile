# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "https://github.com/CommanderK5/packer-centos-template/releases/download/0.7.2/vagrant-centos-7.2.box"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    # vb.gui = true
  
    # Customize the amount of memory on the VM:
    vb.memory = "4096"
    for n in [1, 2, 3]
      file_to_disk = File.realpath( "." ).to_s + "/disk-#{n}.vdi"

      if ! File.exist?(file_to_disk)
        vb.customize [
            'createhd',
            '--filename', file_to_disk,
            '--format', 'VDI',
            '--size', 1024 # 1 GB
            ]
        vb.customize [
          'storageattach', :id,
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
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
    sudo yum install -y docker-engine
    sudo systemctl enable docker.service
    sudo systemctl start docker
    for disk in b c d; do
      if [ ! -d "/mnt/disk-${disk}" ]; then
        mkdir -p /mnt/disk-${disk}
        mkfs.xfs /dev/sd${disk}
        sudo tee -a /etc/fstab <<-DISK
/dev/sd${disk} /mnt/disk-${disk} xfs rw,relatime,attr2,inode64,noquota 0 0
        mount /mnt/disk-${disk}
DISK
      fi
    done
    curl -sSL https://minimesos.org/install | sh
    echo 'export PATH=$PATH:/root/.minimesos/bin' >> /etc/profile.d/minimesos.sh
    source /etc/profile.d/minimesos.sh
    minimesos
  SHELL
end