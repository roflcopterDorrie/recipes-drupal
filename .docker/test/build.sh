#!/bin/bash
set -e

# Build the docker images.
docker build --build-arg LOCAL_CERT=false -f .docker/test/drupal.Dockerfile -t recipes/drupal-local .
docker build -f .docker/test/nginx.Dockerfile -t recipes/nginx-local .

# Destroy the existing instance.
docker compose -f ./.docker/test/docker-compose.yml down -v

# Start it up.
docker compose -f ./.docker/test/docker-compose.yml up -d

# Install the site config.
docker compose -f ./.docker/test/docker-compose.yml exec -it drupal drush sql:drop -y
docker compose -f ./.docker/test/docker-compose.yml exec -it drupal drush si --existing-config -y

# Run any updates.
docker compose -f ./.docker/test/docker-compose.yml exec -it drupal drush updb -y
docker compose -f ./.docker/test/docker-compose.yml exec -it drupal drush cr

# Import test content.
docker compose -f ./.docker/test/docker-compose.yml exec -it drupal drush en default_content
docker compose -f ./.docker/test/docker-compose.yml exec -it drupal drush en recipes_default_content

# Create a recipe user.
docker compose -f ./.docker/test/docker-compose.yml exec -it drupal drush user:create recipe_user --mail="example@example.com" --password="password"
docker compose -f ./.docker/test/docker-compose.yml exec -it drupal drush user:role:add recipes_user recipe_user

# Run playwright tests
DDEV_IP=$(ddev exec ip route | grep default | awk '{print $3}')
if [ -z "$DDEV_IP" ]; then
    exit 1
fi
ddev exec BASE_URL="http://${DDEV_IP}:9080" npx playwright test