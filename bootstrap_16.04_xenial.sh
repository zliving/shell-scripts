#!/bin/bash
echo "*** Adding PHP 5.6 Repo ***"
sudo add-apt-repository ppa:ondrej/php
echo "*** Updating package list ***"
sudo apt-get update
echo "*** Installing PHP 5.6 and components ***"
sudo apt-get install -y python-software-properties vim curl nginx php5.6 php5.6-fpm php5.6-curl php5.6-soap php5.6-mysql php5.6-odbc php5.6-xmlrpc php5.6-mcrypt php5.6-mbstring php5.6-geoip php5.6-memcache php5.6-xdebug libgss3 libstdc++6 git-core libpcre3-dev php5.6-zip nfs-common make

echo "*** Installing PHP-AUTH ***"
sudo apt-get install -y php-auth php5.6-dev php5.6-xml

echo "*** Install Python Packages ***"
sudo apt-get install -y python-pip
sudo pip install openpyxl 
sudo pip install pymysql 
sudo pip install xlrd 
sudo pip install requests
sudo pip install python-dotenv
sudo pip install pymssql
sudo pip install python-dateutil 

echo "*** Enabling MCRYPT ***"
sudo phpenmod mcrypt

echo "*** pecl Install oAuth ***"
pecl install oauth-1.2.3
touch /etc/php/5.6/fpm/conf.d/oauth.ini 
echo "extension=oauth.so" > /etc/php/5.6/fpm/conf.d/oauth.ini

echo "*** Installing Composer ***"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

echo "*** Configuring Xdebug ***"
cat << EOF | sudo tee -a /etc/php/5.6/fpm/conf.d/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

echo "*** configure fix_path and error_reporting for php5.6-FPM ***"
sed -i "s/;cgi.fix_pathinfo=1 /cgi.fix_pathinfo=0/" /etc/php/5.6/fpm/php.ini

echo "*** Make PHP5-FPM use a TCP Connection ***"
sed -i "s/listen = .*/listen = 127.0.0.1:9000/" /etc/php/5.6/fpm/pool.d/www.conf

echo "*** turn off sendfile in nginx.conf ***"
sed -i "s/sendfile on/sendfile off/" /etc/nginx/nginx.conf

echo "*** enable websites ***"
sudo rm -rf /etc/nginx/sites-enabled/*

echo "*** set permissions ***"
sudo chown -R www-data:www-data /var/www/*
sudo chmod -R 775 /var/www/*

echo "*** Restarting PHP-FPM ***"
sudo service php5.6-fpm restart

echo "*** Restarting NGinx ***"
sudo service nginx restart

# TO GET CONFIG FILES WORKING INSERT THE LINE fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name; INTO location ~ \.php$ {}