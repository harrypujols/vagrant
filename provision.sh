#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='root'
PROJECT=$1
IP=$2

# update / upgrade
sudo apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

# install apache
sudo apt-get install -y apache2

# install php latest
sudo apt-get install -y php libapache2

# install composer
sudo apt-get install -y zip unzip composer

# install mysql and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install mysql-server php-mysql

# install phpmyadmin and give password(s) to installer
# for simplicity I'm using the same password for mysql and phpmyadmin
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin
sudo phpenmod mcrypt

# setup mysql user
MY=$(cat <<EOF
[client]
user=root
password=root
host=localhost
EOF
)
echo "$MY" > /home/vagrant/.my.cnf

# create a database
mysql --user=$PASSWORD --password=$PASSWORD -e "create database $PROJECT;"

# enable mod_rewrite
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod expires
sudo a2enmod include

# restart apache
service apache2 restart

# symlink site's folder
sudo ln -s /var/www/html /home/vagrant/$PROJECT

# install git
sudo apt-get -y install git

# all done
printf "\033[0;36m$PROJECT site running on \033[0;35mhttp://$IP\033[0m"
