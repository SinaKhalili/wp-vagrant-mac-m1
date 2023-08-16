# 
# This script will run as part of the vagrant provisioning process.
# (i.e. when you run `vagrant up` or `vagrant provision`)
# It will install all the required software and set up the WordPress
# site. Wordpress should be available on http://localhost:8081
# 

# Update and upgrade the system
sudo apt-get update
sudo apt-get upgrade -y

    # Update package lists
sudo apt-get update
sudo apt-get remove -y unattended-upgrades
sudo apt-get autoremove -y
sudo systemctl disable apt-daily.service
sudo systemctl disable apt-daily.timer

sleep 10

# Install Nginx
sudo apt-get install nginx -y

# Start Nginx
sudo systemctl start nginx

# Install MySQL and set up a database for WordPress
echo "mysql-server mysql-server/root_password password root" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password root" | sudo debconf-set-selections
sudo apt-get install mysql-server -y
sudo mysql -uroot -proot -e "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
sudo mysql -uroot -proot -e "CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'password';"
sudo mysql -uroot -proot -e "GRANT ALL ON wordpress.* TO 'wordpress'@'localhost';"
sudo mysql -uroot -proot -e "FLUSH PRIVILEGES;"

# Install PHP and required modules
sudo apt-get install php-fpm php-mysql -y

# Download and install WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# Download WordPress using WP-CLI
cd /var/www/html
sudo wp core download --allow-root

# Set up WordPress configuration
sudo wp config create --dbname=wordpress --dbuser=wordpress --dbpass=password --allow-root

# Change ownership of the WordPress files to the web server user
sudo chown -R www-data:www-data /var/www/html

# Create Nginx configuration for WordPress
echo "server {
    listen 80;
    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \\.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}" | sudo tee /etc/nginx/sites-available/wordpress

# Enable the configuration
sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

sudo wp core install --url=localhost --title=TestSite --admin_user=admin --admin_password=password --admin_email=test@example.com --allow-root

# Modify wp-config.php
awk '
/\/\* That'\''s all, stop editing! Happy publishing. \*\// {
    print "if (isset($_SERVER['\''HTTP_HOST'\''])) {"
    print "    define('\''WP_HOME'\'', '\''http://'\'' . $_SERVER['\''HTTP_HOST'\'']);"
    print "    define('\''WP_SITEURL'\'', '\''http://'\'' . $_SERVER['\''HTTP_HOST'\'']);"
    print "}"
    print $0
    next
}
1' /var/www/html/wp-config.php | sudo tee /var/www/html/wp-config.php.tmp > /dev/null && sudo mv /var/www/html/wp-config.php.tmp /var/www/html/wp-config.php

# Restart Nginx and PHP-FPM to apply the changes
sudo systemctl restart nginx
sudo systemctl restart php7.4-fpm