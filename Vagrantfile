Vagrant.configure(2) do |config|

  config.vm.define "puppet", primary: true do |puppet|
    puppet.vm.hostname = "puppet"
    puppet.vm.box = "puppetlabs/centos-7.0-64-puppet"
    puppet.vm.network "private_network", ip: "10.13.37.2"
    puppet.vm.synced_folder "code", "/etc/puppetlabs/code"

    puppet.vm.provider :virtualbox do |vb|
      vb.memory = "3072"
    end

    puppet.vm.provision "shell", path: "puppetupgrade.sh"

    puppet.vm.provision "shell",
      inline: "/opt/puppetlabs/bin/puppet apply /etc/puppetlabs/code/environments/production/manifests/site.pp"

  end

  config.vm.define "node1", primary: true do |node1|
    node1.vm.hostname = "node1"
    node1.vm.box = "puppetlabs/centos-7.0-64-puppet"
    node1.vm.network "private_network", ip: "10.13.37.3"

    node1.vm.provision "shell", path: "puppetupgrade.sh"
    node1.vm.provision "shell", inline: "/bin/systemctl start puppet.service"
  end

end
