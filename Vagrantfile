# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

def check_plugin()
  unless Vagrant.has_plugin?("vagrant-vbguest")
    raise 'vagrant-vbguest is not installed - please execute "vagrant plugin install vagrant-vbguest" !'
  end
end

check_plugin()

yaml = YAML.load_file('./config.yaml')
nodes = yaml['nodes']
IMAGE = yaml['machine']['image']
MEMORY = yaml['machine']['memory']
CPUS = yaml['machine']['cpus']
BASENAME = "node-"
DISK_DIR = "./disks"

Vagrant.configure(2) do |config|

  config.vm.box = IMAGE


  config.vm.provider "virtualbox" do |vb|
    vb.customize ['modifyvm', :id, '--nictype1', 'virtio']
    vb.memory = MEMORY
    vb.cpus = CPUS
    vb.linked_clone = true
  end

  # Configure each machine independently
  nodes.each do |node|
    index = (yaml['nodes'].index(node)+1).to_s
    name = BASENAME+index

    node_ip = node['ip']
    node_role = node['role']
    node_disks = node['disks']

    config.vm.define name do |box|
      box.vm.network "private_network", ip: node_ip
      box.vm.hostname = name

      box.vm.provider "virtualbox" do |vb|
        vb.name = name
        # Configure extra disks
        unless node_disks.nil?
          node_disks.each do |disk|
            disk_index = (node_disks.index(disk)).to_s
            disk_file = File.join(DISK_DIR, "disk-#{name}-#{disk_index}.vdi")
            disk_size = disk['size']

            # Create disk files if they dont exist
            unless File.exists?(disk_file)
              vb.customize [ "createhd",
                             "--filename", disk_file,
                             "--size", 1024 * disk_size ]
            end
            vb.customize [ "storageattach", :id,
                           "--storagectl", "SCSI",
                           "--port", 3+disk_index.to_i,
                           "--device", 0,
                           "--type", "hdd",
                           "--medium", disk_file ]
          end
        end
      end

      box.vm.provision "shell" do |s|
        s.env = {
            "NODE_IP"   => node_ip,
            "NODE_ROLE" => node_role
        }
        s.privileged = true
        s.path = "provision.sh"
      end

    end
  end
end
