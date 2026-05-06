Installation

Install DDEV
https://docs.ddev.com/en/stable/users/install/ddev-installation/

# Install a production ready version of the site

Create a folder.
Create a docker-compose.yml file 

```
services:
  # The Drupal image you built with GitHub Actions
  drupal:
    image: ghcr.io/roflcopterdorrie/recipes-drupal:latest
    restart: always
    env_file: .env
    volumes:
      # Use named volumes for persistent data (standard practice)
      - drupal_code:/opt/drupal
      - drupal_files:/opt/drupal/web/sites/default/files
    depends_on:
      - db

  # Database container
  db:
    image: mariadb:10.11
    restart: always
    env_file: .env
    volumes:
      - db_data:/var/lib/mysql

  # Nginx web server to route traffic to Drupal
  nginx:
    image: nginx:alpine
    restart: always
    ports:
      - "80:80"   # External traffic
      - "443:443" # HTTPS
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - drupal_code:/opt/drupal:ro  # Mount the SAME volume as Read-Only
      - drupal_files:/opt/drupal/web/sites/default/files:ro
    depends_on:
      - drupal

volumes:
  drupal_files:
  db_data:
  drupal_code: 
```

Create a nginx.conf file

```
server {
    listen 80;
    server_name localhost;
    root /opt/drupal/web; 
    index index.php;

    # Maximum file upload size
    client_max_body_size 100M;

    location / {
        # This handles Drupal's "Clean URLs"
        try_files $uri $uri/ /index.php?$query_string;
    }

    # If file not found, ask index.php for it.
    location @rewrite {
        rewrite ^ /index.php;
    }

    # If css or js is not found, as index.php.
    location ~ ^/sites/.*/files/(css|js|styles)/ {
        try_files $uri @rewrite;
    }

    # Handle PHP execution by passing it to the 'drupal' container
    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass drupal:9000; # 'drupal' matches your service name in docker-compose
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME /opt/drupal/web$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    # Better handling for CSS/JS aggregation in Drupal 10.1+
    location ~ ^/sites/.*/files/(css|js|styles)/ {
        try_files $uri @rewrite;
    }

    # Deny access to private files and backups
    location ~* \.(engine|inc|install|make|module|profile|po|sh|.*sql|theme|twig|tpl\.php|xtmpl)$|^(?:\..*|composer\.(json|lock)|web\.config)$ {
        deny all;
    }

    # Deny access to the vendor directory
    location ^~ /vendor/ {
        deny all;
    }

    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
}
```

Then run `docker compose up -d`

This should build a production ready version of the site for you.
