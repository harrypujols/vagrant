#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='root'
PROJECT='public'

# create project folder
HTML=$(cat <<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Web page</title>
  </head>
  <body>
    <h1>Hello <?php echo "World"; ?></h1>
    <a href="http://166.166.66.60/phpmyadmin/">Go to PHPMyAdmin</a>
  </body>
</html>
EOF
)

if [ ! -d "/vagrant/${PROJECT}" ]; then
  mkdir "/vagrant/${PROJECT}"
  echo "${HTML}" > /vagrant/$PROJECT/index.php
fi

# update / upgrade
sudo apt-get update
sudo apt-get -y upgrade

# cosmetic terminal prompt
echo 'export "\[\033[0;37m\][\W] \[\033[0m\]"' >> /home/vagrant/.bash_profile

# install apache
sudo apt-get install -y apache2

if ! [ -L /var/www ]; then
  rm -rf /var/www/html
  ln -fs /vagrant /var/www/html
fi

# install php5
sudo apt-get install -y php5 libapache2

# install mysql and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install mysql-server
sudo apt-get install -y php5-mysql

# create a database
mysql -uroot -e "create database ${PROJECT};"

# install phpmyadmin and give password(s) to installer
# for simplicity I'm using the same password for mysql and phpmyadmin
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin
sudo php5enmod mcrypt

# setup mysql user
MY=$(cat <<EOF
[client]
user=root
password=root
host=localhost
EOF
)
echo "${MY}" > /home/vagrant/.my.cnf

# setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
    DocumentRoot "/var/www/html/${PROJECT}"
    <Directory "/var/www/html/${PROJECT}">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/$PROJECT.conf

# enable mod_rewrite
sudo a2enmod rewrite

# restart apache
service apache2 restart

# install git
sudo apt-get -y install git

# all done
echo "${PROJECT} site running on http://166.166.66.60/${PROJECT}"
