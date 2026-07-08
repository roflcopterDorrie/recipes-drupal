#!/usr/bin/env bash
set -e

docker compose pull
docker compose up -d
docker compose exec -it drupal drush updb -y
docker compose exec -it drupal drush cim -y
docker compose exec -it drupal drush cr