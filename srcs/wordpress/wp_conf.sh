#!/bin/bash
set -e

if ! command -v wp &> /dev/null; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

cd /var/www/wordpress
chmod -R 755 /var/www/wordpress/
chown -R www-data:www-data /var/www/wordpress

# Attendre que MariaDB soit prêt
echo "Waiting for database connection..."
timeout=60
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

# Uniquement installer WordPress s'il n'est pas déjà installé
if [ ! -f wp-config.php ]; then
    wp core download --allow-root
    wp config create --dbhost=mariadb --dbname="$MYSQL_DB" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --allow-root
    
    echo "Installing WordPress..."
    wp core install --url="$DOMAIN_NAME" --title="$WP_TITLE" --admin_user="$WP_ADMIN_N" --admin_password="$WP_ADMIN_P" --admin_email="$WP_ADMIN_E" --allow-root
    wp user create "$WP_U_NAME" "$WP_U_EMAIL" --user_pass="$WP_U_PASS" --role="$WP_U_ROLE" --allow-root
fi

sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 9000|' /etc/php/7.4/fpm/pool.d/www.conf
mkdir -p /run/php
exec /usr/sbin/php-fpm7.4 -F