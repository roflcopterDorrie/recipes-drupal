# STAGE 1: Optimization (The "Chef")
FROM composer:2 as builder
# Change this to match the official Drupal image path
WORKDIR /opt/drupal 
COPY composer.json composer.lock ./

RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs

# STAGE 2: Production (The "Plate")
FROM drupal:11-fpm-alpine
WORKDIR /opt/drupal

# 1. Copy the vendor folder (The engine)
COPY --from=builder /opt/drupal/vendor /opt/drupal/vendor  

# 2. NEW: Copy the modules and themes downloaded by Composer in Stage 1
COPY --from=builder /opt/drupal/web/modules/contrib /opt/drupal/web/modules/contrib
COPY --from=builder /opt/drupal/web/themes/contrib /opt/drupal/web/themes/contrib

# 3. Copy your custom code (your themes, your modules, and settings.php)
COPY . /opt/drupal

# Clean up
RUN rm -rf /opt/drupal/.ddev /opt/drupal/.git

# Ensure the files directory exists in the correct location
RUN mkdir -p /opt/drupal/web/sites/default/files

# Set permissions
RUN chown -R www-data:www-data /opt/drupal/web/sites/default/files
