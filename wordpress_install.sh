###############

echo "Installing Dependencies"
apt-get install -y curl
apt-get install -y sudo
apt-get install -y mc
echo "Installed Dependencies"

WORDPRESS_DIR=/var/www/wordpress

# Install Apache, PHP, and necessary PHP extensions
echo "Installing Apache and PHP..."
sudo apt install apache2 libapache2-mod-php php-gd php-sqlite3 php-mysql php-mbstring php-xml php-zip -y

# Enable Apache mods
sudo a2enmod rewrite

# Install Wordpress
echo "Installing Wordpress..."
sudo mkdir -p ${WORDPRESS_DIR}
cd ${WORDPRESS_DIR}/..
sudo wget https://wordpress.org/latest.tar.gz -O latest.tar.gz
sudo tar -xzf latest.tar.gz -C ${WORDPRESS_DIR} --strip-components=1
sudo rm latest.tar.gz
sudo chown -R www-data:www-data ${WORDPRESS_DIR}

# Configure Apache to serve Wordpress
echo "Configuring Apache..."
WORDPRESS_CONF="/etc/apache2/sites-available/wordpress.conf"
echo "<VirtualHost *:80>
     ServerName localhost:80
     DocumentRoot ${WORDPRESS_DIR}
     <Directory ${WORDPRESS_DIR}/>
          Options FollowSymlinks
          AllowOverride All
          Require all granted
     </Directory>
    
     <Directory ${WORDPRESS_DIR}/>
            RewriteEngine on
            RewriteBase /
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteRule ^(.*) index.php [PT,L]
    </Directory>
</VirtualHost>" | sudo tee $WORDPRESS_CONF


sudo a2ensite wordpress.conf
sudo a2dissite 000-default.conf
sudo systemctl restart apache2

echo "Wordpress installation completed successfully!"
echo "You can access Wordpress at: http://${DOMAIN_OR_IP}/"

echo "Cleaning up"
apt-get -y autoremove
apt-get -y autoclean
echo "Cleaned"

##############