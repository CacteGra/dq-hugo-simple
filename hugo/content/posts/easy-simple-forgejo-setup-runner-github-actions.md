---
title: "Easy Simple Forgejo Setup with Runner ala Github Action"
date: 2025-09-01
draft: false
tags: ["dev", "forgejo", "github"]
categories: ["tutorials"]
description: "Run actions on your Forgejo install like you do with Github workflows."
---
Create a **forgejo-runner** folder inside your Forgejo install and write the **docker-compose.yml** file for your Forgejo runner service:
  ```yml
  services:
    docker-in-docker:
      image: docker:dind
      container_name: 'docker_dind'
      privileged: 'true'
      command: ['dockerd', '-H', 'tcp://0.0.0.0:2375', '--tls=false']
      restart: 'unless-stopped'
  
    gitea:
      image: 'code.forgejo.org/forgejo/runner:4.0.0'
      links:
        - docker-in-docker
      depends_on:
        docker-in-docker:
          condition: service_started
      container_name: 'runner'
      environment:
        DOCKER_HOST: tcp://docker-in-docker:2375
      # User without root privileges, but with access to `./data`.
      user: 1001:1001
      volumes:
        - ./data:/data
      restart: 'unless-stopped'
  
      command: '/bin/sh -c "sleep 5; forgejo-runner daemon"'
  ```

Create a setup executable file:
`nano setup.sh`
  ```bash
  #!/usr/bin/env bash
  
  set -e
  
  mkdir -p data
  touch data/.runner
  mkdir -p data/.cache
  
  chown -R 1001:1001 data/.runner
  chown -R 1001:1001 data/.cache
  chmod 775 data/.runner
  chmod 775 data/.cache
  chmod g+s data/.runner
  chmod g+s data/.cache
  ```
Become **root**:

`su`

And run the bash script:

`bash setup.sh`

Register the runner:

`docker exec -it runner /bin/sh`

`forgejo-runner register`

For the instance URL and because our two Forgejo containers are on the same machine locally, input (otherwise put your *domain name*):

`http://your.local.ip.here:3000/`

As for the token, it is available when creating a new running on your Forgejo server under  **Site administration** -> **Actions** -> **Runners** -> **Create new runner**.


Modify **docker-compose.yml** to change the *commad*:
  ```
  command: '/bin/sh -c "while : ; do sleep 1 ; done ;"'
  ```
  to
  ```
  command: '/bin/sh -c "sleep 5; forgejo-runner daemon"'
  ```


## Final thoughts
Adapting workflows from GitHub to Forgejo is a simple matter of adding *https://github.com/* in front of uses except for major actions such as [**action/checkout@v4**](https://code.forgejo.org/actions/checkout).