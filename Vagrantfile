Vagrant.configure("2") do |config|
  
  config.vm.provider :vmware_desktop do |vmware|
    vmware.vmx["ethernet0.pcislotnumber"] = "160"
  end

  config.vm.box = "spox/ubuntu-arm"
  config.vm.box_version = "1.0.0"
  config.vm.network "forwarded_port", guest: 80, host: 8081
  config.vm.provision "shell", path: "scripts/provision.sh"
end
