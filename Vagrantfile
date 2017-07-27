# -*- mode: ruby -*-
# vi: set ft=ruby :

PROJECT='public'
IP='192.168.50.4'

Dir.mkdir(PROJECT) unless File.exists?(PROJECT)

Vagrant.configure('2') do |config|
  config.vm.box = 'bento/ubuntu-16.04'
  config.vm.network 'private_network', ip: IP
  config.vm.synced_folder PROJECT, '/var/www/html', :nfs => { :mount_options => ['dmode=777','fmode=666'] }
  config.vm.provision :shell, path: 'bootstrap.sh', args: PROJECT + " " + IP
end
