---
title: "Caddy Serving Files, Local Subdomains & Environment Variables"
date: 2025-09-17
draft: false
tags: ["dev", "caddy", "docker", "webserver"]
categories: ["tutorials"]
description: "Using Caddy to its full potential serving files and subdomains."
---
**Caddy** web server has the option to directly serve files. It is especially useful when looking to display a static web pages under subdomains alongside more complex solutions.


## Adapting your Docker Compose installation:

Under volumes, add volume you wish Docker to copy to the container so that section should look like this:
  ```
      volumes:
        - ./caddy/Caddyfile:/etc/caddy/Caddyfile
        - ./caddy/static:/srv
        - ./caddy/config:/config
        - ./caddy/data:/data
        - ./subdomain_files:/www/html
  ```


## Caddy configuration

In order to have Caddy serve the files, we have to tell it where the files are located and that it needs to serve them.
  
*root* is the option we must specify, alongside a path, to locate the folder/files. With *\** we can tell Caddy to serve all files within the specified folder, therefore index.html will be our domain's homepage, while other denomination will appear as DOMAIN_NAME/you_other_file.html.

Your **Caddyfile** root path for the domain's files should reflect the path used in **docker-compose.yml**; here */www/html*.

*file_server* tells Caddy to take care of serving them.

Overall **Caddyfile** should look like this:
  ```caddyfile
  {$DOMAIN_NAME} {
      root * /www/html
      file_server
  }
  www.{$DOMAIN_NAME} {
      redir https://{$DOMAIN_NAME}{uri}
  }
  ```


## Variables in local dev environment

Another way to use environement variables in Caddy for both development and production is to give a default option. This works best when using subdomain on local machines for example.
  ```caddyfile
  {$SUBDOMAIN_NAME:subdomain.localhost} {
      root * /www/html
      file_server
  }
  www.{$SUBDOMAIN_NAME:subdomain.localhost} {
      redir https://{$SUBDOMAIN_NAME:subdomain.localhost}{uri}
  }
  ```
