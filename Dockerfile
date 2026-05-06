# STAGE 1: Optimization (The "Chef")
FROM composer:2 as builder
WORKDIR /opt/drupal 
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs
# Ensure index.php and .htaccess are actually created
RUN composer drupal:scaffold

# STAGE 2: Production (The "Plate")
FROM drupal:11-fpm-alpine
WORKDIR /opt/drupal

COPY --from=builder /opt/drupal/vendor /opt/drupal/vendor  
COPY --from=builder /opt/drupal/web/modules/contrib /opt/drupal/web/modules/contrib
COPY --from=builder /opt/drupal/web/themes/contrib /opt/drupal/web/themes/contrib

#COPY web/modules/custom /opt/drupal/web/modules/custom
#COPY web/themes/custom /opt/drupal/web/themes/custom
COPY web/sites/default/settings.php /opt/drupal/web/sites/default/settings.php
COPY config /opt/drupal/config

COPY --from=builder /opt/drupal/web/index.php /opt/drupal/web/index.php
COPY --from=builder /opt/drupal/web/.htaccess /opt/drupal/web/.htaccess

# Finalize permissions - added the 'custom' and 'config' folders here
RUN mkdir -p /opt/drupal/web/sites/default/files && \
    chown -R www-data:www-data /opt/drupal/web/sites/default/files && \
    chown -R www-data:www-data /opt/drupal/web/modules/custom && \
    chown -R www-data:www-data /opt/drupal/web/themes/custom && \
    chown -R www-data:www-data /opt/drupal/config && \
    chown www-data:www-data /opt/drupal/web/sites/default/settings.php
