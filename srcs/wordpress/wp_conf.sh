#!/bin/bash
set -e

#installation de wp cli si besoin
if ! command -v wp &> /dev/null; then
    echo "Installing WP-CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

#preparation du repertoire wp
cd /var/www/wordpress
chmod -R 755 /var/www/wordpress/
chown -R www-data:www-data /var/www/wordpress

# Attendre que MariaDB soit prêt
echo "Waiting for database connection..."
timeout=120
counter=0
while ! mariadb -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "USE ${MYSQL_DB};" 2>/dev/null; do
    sleep 5
    counter=$((counter+5))
    echo "Waiting for database... ${counter}/${timeout}"
    if [ "$counter" -ge "$timeout" ]; then
        echo "Timed out waiting for database"
        exit 1
    fi
done

echo "Database connection established!"

# Uniquement installer WordPress s'il n'est pas déjà installé
if [ ! -f wp-config.php ]; then
    echo "Downloading WordPress core files..."
    wp core download --allow-root

    echo "Creating wp-config.php..."
    wp config create --dbhost=mariadb --dbname="$MYSQL_DB" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --allow-root
    
    echo "Installing WordPress..."
    wp core install --url="$DOMAIN_NAME" --title="$WP_TITLE" --admin_user="$WP_ADMIN_N" --admin_password="$WP_ADMIN_P" --admin_email="$WP_ADMIN_E" --allow-root
    
    echo "Creating additional user..."
    wp user create "$WP_U_NAME" "$WP_U_EMAIL" --user_pass="$WP_U_PASS" --role="$WP_U_ROLE" --allow-root

    echo "WordPress installation complete!"
else
    echo "Wordpress already installedm skipping installation."
fi

#conf de php-fpm
echo "Configuring PHP-FPM..."
mkdir -p /run/php
sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 9000|' /etc/php/7.4/fpm/pool.d/www.conf

echo "Starting PHP-FPM in foreground..."
exec /usr/sbin/php-fpm7.4 -F
