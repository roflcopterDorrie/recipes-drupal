# STAGE 1: Optimization (The "Chef")
FROM composer:2 as builder
WORKDIR /app
COPY composer.json composer.lock ./

# This creates the lean, production-ready vendor folder
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs

# STAGE 2: Production (The "Plate")
FROM drupal:11-fpm-alpine
WORKDIR /var/www/html

# Copy the optimized vendor folder from the builder
COPY --from=builder /app/vendor /var/www/html/vendor

# Copy your site code (themes, modules, etc.)
COPY . /var/www/html

# Clean up DDEV and Git leftovers
RUN rm -rf /var/www/html/.ddev /var/www/html/.git

# Make sure default files exists.
RUN mkdir -p /var/www/html/web/sites/default/files

# Ensure Drupal can write to the files directory
RUN chown -R www-data:www-data /var/www/html/web/sites/default/files
