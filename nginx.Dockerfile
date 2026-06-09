# Grab your freshly built Drupal image that contains all the code
FROM ghcr.io/roflcopterdorrie/recipes-drupal-drupal:latest as drupal_source

# Grab the production Nginx image
FROM nginx:alpine

# Copy ONLY the public web assets from the Drupal image into Nginx
COPY --from=drupal_source /opt/drupal/web /opt/drupal/web

# Copy your configuration file in
COPY nginx.conf /etc/nginx/conf.d/default.conf