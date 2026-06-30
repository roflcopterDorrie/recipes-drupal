# STAGE 1: Optimization (The "Chef")
FROM composer:2 as builder
WORKDIR /opt/drupal 

ARG LOCAL_CERT=false

# Install CA only if running locally
RUN --mount=type=bind,source=./.docker/test,target=/certs \
    if [ "$LOCAL_CERT" = "true" ]; then \
        echo "Installing local Zscaler cert"; \
        cp /zscaler.crt /usr/local/share/ca-certificates/zscaler.crt && \
        update-ca-certificates; \
    else \
        echo "Skipping cert install"; \
    fi

COPY composer.json composer.lock ./
RUN composer install --optimize-autoloader --no-interaction --ignore-platform-reqs --prefer-source
# Ensure index.php and .htaccess are actually created
RUN composer drupal:scaffold

# STAGE 2: Production (The "Plate")
FROM drupal:11-fpm-alpine
WORKDIR /opt/drupal

# Use a prod settings file.
COPY web/sites/default/settings.prod.php /opt/drupal/web/sites/default/settings.php

# Make sure any certificates are copied over from the builder.
COPY --from=builder /usr/local/share/ca-certificates/ /usr/local/share/ca-certificates/
RUN apk add --no-cache ca-certificates && update-ca-certificates

# Add libraries that are needed.    
RUN apk add mariadb-client && \
    apk add --virtual .build-deps $PHPIZE_DEPS && \
    pecl install apcu redis && \
    docker-php-ext-enable apcu redis && \
    apk del .build-deps

# Make sure our composer files are in the final build.
COPY --from=builder /opt/drupal/composer.json /opt/drupal/composer.json
COPY --from=builder /opt/drupal/composer.lock /opt/drupal/composer.lock

# Copy across all the files that composer has just downloaded.
COPY --from=builder /opt/drupal/vendor /opt/drupal/vendor  
COPY --from=builder /opt/drupal/web/modules/contrib /opt/drupal/web/modules/contrib
COPY --from=builder /opt/drupal/web/themes/contrib /opt/drupal/web/themes/contrib

# Add anything custom.
COPY web/themes/custom /opt/drupal/web/themes/custom
COPY web/modules/custom /opt/drupal/web/modules/custom

# Make sure the files folder exists.
RUN mkdir -p /opt/drupal/web/sites/default/files

# Finalize permissions.
RUN chown -R www-data:www-data /opt/drupal/web/sites/default/files && \
    chown -R www-data:www-data /opt/drupal/web/themes/custom

# Copy across all the config files ready for import.
COPY config /opt/drupal/config  
