# STAGE 1: Optimization (The "Chef")
FROM composer:2 as builder
WORKDIR /opt/drupal 
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs
# Ensure index.php and .htaccess are actually created
RUN composer drupal:scaffold
RUN echo "--- DEBUG: STAGE 1 CONTRIB MODULES ---" && ls -la web/modules/contrib/

# STAGE 2: Production (The "Plate")
FROM drupal:11-fpm-alpine
WORKDIR /opt/drupal

# Make sure our composer files are in the final build.
COPY --from=builder /opt/drupal/composer.json /opt/drupal/composer.json
COPY --from=builder /opt/drupal/composer.lock /opt/drupal/composer.lock

# Copy across all the files that composer has just downloaded.

COPY --from=builder /opt/drupal/vendor /opt/drupal/vendor  
COPY --from=builder /opt/drupal/web/modules/contrib /opt/drupal/web/modules/contrib
RUN echo "--- DEBUG: STAGE 2 CONTRIB MODULES ---" && ls -la /opt/drupal/web/modules/contrib
COPY --from=builder /opt/drupal/web/themes/contrib /opt/drupal/web/themes/contrib

# Copy the recipes-theme theme. Remove this once it gets its own repo.
COPY web/themes/custom /opt/drupal/web/themes/custom

# Use a prod settings file.
COPY web/sites/default/settings.prod.php /opt/drupal/web/sites/default/settings.php

# Ensure everything in the web root is readable
RUN chmod -R 755 /opt/drupal/web && \
    chmod -R 755 /opt/drupal/vendor

# Make sure the files folder exists.
RUN mkdir -p /opt/drupal/web/sites/default/files

# Finalize permissions.
RUN chown -R www-data:www-data /opt/drupal/web/sites/default/files && \
    chown -R www-data:www-data /opt/drupal/web/themes/custom
