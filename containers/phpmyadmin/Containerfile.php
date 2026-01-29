FROM php:8.2-fpm-alpine

# Copy the actual application from the `phpmyadmin` image
COPY --from=phpmyadmin /var/www/html /var/www/html
COPY --from=phpmyadmin /etc/phpmyadmin /etc/phpmyadmin

# Enable the default production-ready php.ini
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Add our security patches to php.ini
COPY security.ini $PHP_INI_DIR/conf.d/99-security.ini

