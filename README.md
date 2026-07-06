# Installation

## Development installation

Install DDEV
https://docs.ddev.com/en/stable/users/install/ddev-installation/

## Production installation

Copy `.docker/prod/` into your prod environment.

Update the `.env` file.

Set ports in `docker-compose.yml` under `nginx` if different from 80 and 443.

Start the docker containers and pull the recipe docker image.  
`docker compose up -d`

Import the configuration into the new database  
`docker compose exec drupal drush si --existing-config`

Rebuild cache  
`docker compose exec drupal drush cr`

