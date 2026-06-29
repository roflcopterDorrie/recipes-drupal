#!/bin/bash
set -e

docker build --build-arg LOCAL_CERT=true -f .docker/test/drupal.Dockerfile -t recipes/drupal-local . --progress=plain
docker build -f .docker/test/nginx.Dockerfile -t recipes/nginx-local . --progress=plain

docker compose -f ./.docker/test/docker-compose.yml up

// Run site install and sync config.
// docker compose exec -it drupal drush si -y
// docker compose exec -it drupal drush cim -y
// docker compose exec -it drupal drush updb
// docker compose exec -it drupal drush cr

// Run playwright tests
docker compose -f ./.docker/test/docker-compose.yml down