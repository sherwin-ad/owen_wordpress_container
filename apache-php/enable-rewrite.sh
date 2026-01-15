#!/bin/bash
set -e
# Enable mod_rewrite for WordPress
apache2ctl -M | grep -q rewrite || a2enmod rewrite
# Install PHP MySQL extension if missing
if ! php -m | grep -q mysqli; then
	apt-get update && apt-get install -y libpng-dev libjpeg-dev libwebp-dev libfreetype6-dev && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && docker-php-ext-install gd mysqli
fi
# Start Apache in foreground
exec apache2-foreground
