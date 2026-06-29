#!/bin/bash
set -e

# Build the docker images.
docker build --build-arg LOCAL_CERT=true -f .docker/test/drupal.Dockerfile -t recipes/drupal-local .
docker build -f .docker/test/nginx.Dockerfile -t recipes/nginx-local .

# Destroy the existing instance.
docker compose -f ./.docker/test/docker-compose.yml down -v

# Start it up.
docker compose -f ./.docker/test/docker-compose.yml up -d

# Install the site config.
docker compose -f ./.docker/test/docker-compose.yml exec -it drupal drush sql:drop -y
# CONFIG_UUID=$(grep '^uuid:' config/sync/system.site.yml | awk '{print $2}')
# docker compose -f ./.docker/test/docker-compose.yml exec -it drupal drush config:set system.site uuid "$CONFIG_UUID" -y
docker compose -f ./.docker/test/docker-compose.yml exec -it drupal drush si --existing-config -y

# Run any updates.
docker compose -f ./.docker/test/docker-compose.yml exec -it drupal drush updb -y
docker compose -f ./.docker/test/docker-compose.yml exec -it drupal drush cr


# Run playwright tests
# docker compose -f ./.docker/test/docker-compose.yml down