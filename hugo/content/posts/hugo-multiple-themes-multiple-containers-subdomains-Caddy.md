---
title: "Using multiple themes in Hugo running multiple containers and subdomains in Caddy"
date: 2026-02-09
draft: false
tags: ["dev", "webdev", "hugo"]
categories: ["tutorial"]
description: "Get Caddy to serve more than one Hugo theme."
---
Hugo static site does not allow multiple themes use as such and workarounds have to be found in order to set specific themes for specific parts of the site.  

The following examples will make use of Docker to run another instance of Hugo with a different theme and get Caddy to serve the new site under a subdomain.  

## How to do it
- Add your new Hugo install in **docker-compose.yml** while changing internal container port so as not to be conflicting with your other site when running Docker Compose.
  ```docker
      ports:
        - "5000:1313"
  ```
- Follow up your Caddy config inside **Caddyfile**:
  ```caddyfile
  {$SUBDOMAIN_NAME} {
      reverse_proxy new_hugo_container_name:1313
  }
  www.{$SUBDOMAIN_NAME} {
      redir https://{$SUBDOMAIN_NAME}{uri}
  }
  ```  

## Other possibilities
There are also other ways to do it such as [here](https://shantanugoel.com/notes/braindump/hugo-multiple-themes/) and [there](https://discourse.gohugo.io/t/two-themes-as-separate-hugo-directories-deployed-to-the-same-website/27899/4).