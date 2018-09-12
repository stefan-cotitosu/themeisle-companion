#!/bin/bash

set -e


wp config create --dbuser="root" --dbhost="$DB_HOST" --dbname="$MYSQL_DATABASE" --dbpass="$MYSQL_ROOT_PASSWORD" && chmod 777 -R  /var/www/html/wp-config.php

mysql -u root --password="$MYSQL_DATABASE" -h db -e "create database IF NOT EXISTS $MYSQL_DATABASE"

wp core install --url="$URL" --title='ObrbitFox' --admin_user=admin --admin_password=admin --admin_email=admin@admin.com --skip-email

wp plugin delete akismet
wp plugin delete hello.php


wp plugin install ari-adminer --activate

wp rewrite structure '%postname%'
wp rewrite flush


wp config set WP_ASYNC_TASK_SALT aswDvi2HheLXmsdAweiTmy8ekYu3duZxsmNjsf4HUnYQvVJu6NJueXmDGjoaMxab --add --type=constant
wp config set "gearman_server" "array( '127.0.0.1:4730' )" --add --raw --type=variable
wp config set WP_MINIONS_BACKEND 'gearman' --add --type=constant
wp config set DISABLE_WP_CRON true --raw --add --type=constant
wp config set TEST_GROUND true --raw --add --type=constant

wp plugin activate --all
mysql -u root --password="$MYSQL_DATABASE" -h db -e 'create database IF NOT EXISTS gearman'
gearmand -d
supervisord -c /etc/supervisor/supervisord.conf
/etc/init.d/cron start
  
#Run base image entrypoint.
docker-entrypoint. sh