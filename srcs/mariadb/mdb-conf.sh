#!/bin/bash

set -e

#init mdb si pas initialisé
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

#demarrage service mariadb
service mariadb start
sleep 5

# Attendre que MariaDB soit prêt
counter=0
while ! mysqladmin ping -u root --silent; do
    sleep 1
    counter=$((counter+1))
    if [ "$counter" -ge 30 ]; then
        echo "Timeout waiting for MariaDB to start"
        exit 1
    fi
done

#conf seulement si base n'existe pas encore
if ! mariadb -u root -e "USE ${MYSQL_DB};" 2>/dev/null; then
    echo "Creating MariaDB database and user..."

    #conf initiale sans mdp
    mariadb -u root <<EOF 
CREATE DATABASE IF NOT EXISTS ${MYSQL_DB} CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DB}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    echo "Database and user created."
fi

echo "Shutting down MariaDB..."
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

echo "Starting MariaDB in foreground..."
exec mysqld_safe --port=3306 --bind-address=0.0.0.0

