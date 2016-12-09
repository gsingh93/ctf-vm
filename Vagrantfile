# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision :shell, :path => "provision.sh", :privileged => false
  config.ssh.forward_agent = true

  # Optionally mount a folder containing the CTF problems
  ctf_path = ENV['CTF_PATH']
  if ctf_path
    config.vm.synced_folder ctf_path, "/home/vagrant/ctf"
  end

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 4096
    vb.cpus = 4
  end
end
