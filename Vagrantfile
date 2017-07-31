# -*- mode: ruby -*-
# vi: set ft=ruby :

PROJECT='public'
IP='166.168.49.4'

Dir.mkdir(PROJECT) unless File.exists?(PROJECT)

Vagrant.configure('2') do |config|
  config.vm.box = 'bento/ubuntu-16.04'
  config.vm.network 'private_network', ip: IP
  config.vm.network :forwarded_port, guest: 22, host: 2201, id: 'ssh', auto_correct: true
  config.vm.synced_folder './public', '/var/www/html', :mount_options => ['dmode=777','fmode=666']
  config.vm.provision :shell, path: 'bootstrap.sh', args: PROJECT + " " + IP
end
