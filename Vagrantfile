# -*- mode: ruby -*-
# vi: set ft=ruby :

PROJECT='public'

Dir.mkdir(PROJECT) unless File.exists?(PROJECT)

Vagrant.configure('2') do |config|
  config.vm.box = 'bento/ubuntu-16.04'
  config.vm.network 'private_network', ip: '166.166.66.60'
  config.vm.synced_folder PROJECT, '/var/www/html', :nfs => { :mount_options => ['dmode=777','fmode=666'] }
  config.vm.provision :shell, path: 'bootstrap.sh', args: PROJECT
end
