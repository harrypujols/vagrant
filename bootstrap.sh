#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='root'
PROJECT=$1
IP=$2

# create project folder
HTML=$(cat <<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Vagrant Box</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
  </head>
  <body>
    <div class="container">
      <h1>Hello <?php echo "World"; ?></h1>
      <p class="lead">Go to PHPMyAdmin</p>
      <p><a class="btn btn-primary" href="http://166.166.66.60/phpmyadmin/">PHPMyAdmin</a></p>
      <p>
        user: <b>root</b><br>
        password: <b>root</b>
      </p>
    </div>
  </body>
</html>
EOF
)


if [ ! "$( ls -A /var/www/html )" ]; then
  echo -e "${HTML}" > /var/www/html/index.php
fi

sudo ln -s /var/www/html /home/vagrant/public

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
echo "${MY}" > /home/vagrant/.my.cnf

# create a database
mysql --user=$PASSWORD --password=$PASSWORD -e "create database ${PROJECT};"

# setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName $PROJECT.local
	  ServerAlias www.$PROJECT.local
    DocumentRoot /var/www/html
    <Directory "/var/www/html">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)

echo "${VHOST}" > /etc/apache2/sites-available/$PROJECT.local.conf
sudo a2ensite $PROJECT.local.conf

# enable mods
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod expires
sudo a2enmod include

# change apache configurations
sudo sed -i "/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/" /etc/apache2/apache2.conf

# restart apache
sudo service apache2 restart

# install git
sudo apt-get -y install git

# all done
printf "\033[0;36m${PROJECT} site running on \033[0;35mhttp://${IP}\033[0m"
