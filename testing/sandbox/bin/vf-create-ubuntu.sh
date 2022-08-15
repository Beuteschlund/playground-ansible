#!/usr/bin/bash

[[ ! -e Vagrantfile ]] && touch Vagrantfile
cat > Vagrantfile << EOF
# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
ENV["LC_ALL"] = "en_US.UTF-8"

# DELETE OR ADD FURTHER ENTRIES DOWN BELOW
# AND CHANGE IPs & HOSTNAMES, IF NEEDED
boxes = [
    {
        :name => "main",
        :cpus => "2",
        :memory => "2048",
        :address => "192.168.56.10"
    },
    {
        :name => "leonardo",
        :cpus => "1",
        :memory => "2048",
        :address => "192.168.56.11"
    },
    {
        :name => "raphael",
        :cpus => "1",
        :memory => "2048",
        :address => "192.168.56.12"
    },
    {
        :name => "donatello",
        :cpus => "1",
        :memory => "2048",
        :address => "192.168.56.13"
    },
    {
        :name => "michelangelo",
        :cpus => "1",
        :memory => "2048",
        :address => "192.168.56.14"
    }
]

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/jammy64"
  config.ssh.forward_agent = true
  boxes.each do |vars|
    config.vm.define vars[:name] do |machine|
      machine.vm.hostname = vars[:name]
      machine.vm.provider :virtualbox do |vb|
        vb.name = vars[:name]
        vb.customize ["modifyvm", :id, "--memory", vars[:memory]]
        vb.customize ["modifyvm", :id, "--cpus", vars[:cpus]]
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      end
      machine.vm.network :private_network, ip: vars[:address]
      if machine.vm.hostname == 'main'
        machine.vm.synced_folder "./shared/ubuntu", "/vagrant", type: "nfs", nfs_version: 4, nfs_udp: false, create: true
        machine.vm.provision "file", source: "./certificates/id_rsa", destination: "~/keyfile"
        machine.vm.provision "shell", path: "./bin/install-certificate-main.sh"
        machine.vm.provision "shell", path: "./bin/packages-apt-main.sh"
      else
        machine.vm.synced_folder ".", "/vagrant", disabled: true
        machine.vm.provision "file", source: "./certificates/id_rsa.pub", destination: "~/main.pub"
        machine.vm.provision "shell", path: "./bin/install-certificate-node.sh"
      end
    end
  end
end
EOF

exit 0;