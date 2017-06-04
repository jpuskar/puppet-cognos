# -*- mode: ruby -*-

Vagrant.configure("2") do |config|
    # Every Vagrant virtual environment requires a box to build off of.
    #config.vm.box = "puppetlabs/centos-7.2-64-puppet"

    config.vm.box = "bento/centos-7.3"
    # Assign this VM to a host-only network IP, allowing you to access it
    # via the IP.
    config.vm.provider 'virtualbox' do |vb|
        vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
        vb.gui = false
        vb.memory = 6144
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
        vb.customize ["modifyvm", :id, "--hpet", "on"]
    end

    # Second network interface, vm's will all exist on this network
    ip = "192.168.44.35"
    config.vm.network :private_network, ip: ip
    config.vm.network :forwarded_port, guest: 9300, host: 9393

    $script = <<SCRIPT
echo I am provisioning...
export FACTER_is_vagrant='true'
[ -d /tmp/modules/cognos ] || mkdir -p /tmp/modules/cognos
mount | grep /tmp/modules/cognos || mount --bind /vagrant /tmp/modules/cognos
rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install -y puppet-agent
export PATH=$PATH:/opt/puppetlabs/bin
puppet module install puppetlabs-concat
puppet module install puppetlabs-stdlib
puppet module install crayfishx-firewalld
puppet module install puppet-selinux
# puppet module install puppet-nginx
puppet module install jpuskar-db2
puppet module install jhoblitt-nsstools
puppet apply --modulepath '/tmp/modules:/etc/puppetlabs/code/environments/production/modules' -e "include '::db2'"
puppet apply --modulepath '/tmp/modules:/etc/puppetlabs/code/environments/production/modules' -e "include '::cognos'"
SCRIPT

    config.vm.provision "shell", inline: $script

end
