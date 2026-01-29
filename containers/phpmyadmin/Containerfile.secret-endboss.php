FROM dunglas/frankenphp AS frankenphp

# Enable the default production-ready php.ini
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Add our security patches to php.ini
COPY security.ini $PHP_INI_DIR/conf.d/99-security.ini


# add additional extensions - requires root privileges
RUN install-php-extensions \
    pdo_mysql \
    gd \
    intl \
    zip \
    opcache
# ----------------------------------------------------------------------

FROM gcr.io/distroless/cc-debian12

ENV PERSISTENT_RUNTIME_DEPS=""
ENV PWD=/app
ENV SERVER_NAME=:80


# Download the frankenphp stand-alone binary
COPY --from=frankenphp /usr/local/bin/frankenphp /frankenphp
COPY --from=frankenphp /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions

# Get the application Code
COPY --from=phpmyadmin /var/www/html /app
COPY --from=phpmyadmin /etc/phpmyadmin /etc/phpmyadmin

WORKDIR /app
ENTRYPOINT ["/frankenphp", "php-server", "--root", "/app"]