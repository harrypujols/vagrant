# vagrant
A portable LAMP virtual box

## how to use
- Download [Vagrant](https://www.vagrantup.com)
- Download [Virtual Box](https://www.virtualbox.org)
- In this directory, run `vagrant up`
- Profit

## to set up new sites
connect to the virtual box
```bash
$ vagrant ssh
```

edit the site's configuration file
```bash
$ sudo vim /etc/apache2/sites-available/foo.conf
```

add the server name to the file
```xml
<VirtualHost *:80>
  ServerName foo.com
  ServerAlias www.example.com
  [...]
```

activate the host
```bash
$ sudo a2ensite foo
$ sudo service apache2 restart
```

## setting up the local host
in your local, access the hosts file
```bash
$ sudo vim /etc/hosts
```
save the IP into the file
```shell
166.166.66.60 foo.com
```

## database ssh credentials

**MySQL Host:**    127.0.0.1

**User:**         root

**Password:**     root

**SSH Host:**     foo.com

**SSH User:**     vagrant

**SSH Password:** vagrant

**SSH Port:**     22
