#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='root'
PROJECT=$1
IP=$2

# update / upgrade
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

# install php latest
apt-get install -y php libapache2

# add php packages
add-apt-repository -y ppa:ondrej/php
apt-get update
apt-get install -y php-uploadprogress
phpenmod uploadprogress

# install composer
apt-get install -y zip unzip composer

# install mysql and give password to installer
debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
apt-get install -y mysql-server php-mysql

# install phpmyadmin and give password(s) to installer
# for simplicity I'm using the same password for mysql and phpmyadmin
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
apt-get install -y phpmyadmin
phpenmod mcrypt

# setup mysql user
MY=$(cat <<EOF
[client]
user=root
password=root
host=localhost
EOF
)
echo "$MY" > /home/vagrant/.my.cnf

# install apache
apt-get install -y apache2

# enable mods
a2enmod rewrite
a2enmod headers
a2enmod expires
a2enmod include

# change apache configurations
sed -i "/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/" /etc/apache2/apache2.conf

# setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
    DocumentRoot "/var/www/$PROJECT"
    <Directory "/var/www/$PROJECT">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)

echo "$VHOST" > /etc/apache2/sites-available/default.conf


# install webmin
echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
wget http://www.webmin.com/jcameron-key.asc
apt-key add jcameron-key.asc
apt-get update
apt-get install -y webmin

# clean up
rm jcameron-key.asc

# allow <? in php assuming php latest is 7.0
# in Webin check on folder /etc/php/ to point to correct config file
sed -i "s/short_open_tag = .*/short_open_tag = On/" /etc/php/7.0/apache2/php.ini

# restart apache
service apache2 restart

# all done
echo "Local webmin running on https://$IP:10000"
printf "\033[0;36m$PROJECT site running on \033[0;35mhttp://$IP\033[0m"
