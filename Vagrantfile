# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "bento/debian-7.9"
  config.vm.hostname = "bayes1.dev.osf.vagrant.local"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
    config.cache.scope = :box
  end

  config.vm.synced_folder ".", "/vagrant", 
    type: "rsync", rsync__exclude: [".git/", "vagrant"], 
    rsync__args: ["--verbose", "--archive", "--delete", "-z"]

  $provision = <<-END
module_dir=/etc/puppet/modules
apt-get -y install puppet bundler rake git
test -L ${module_dir} || mv ${module_dir} ${module_dir}.old
ln -sf /vagrant/spec/fixtures/modules ${module_dir}
END

  config.vm.provision "shell", inline: $provision
end