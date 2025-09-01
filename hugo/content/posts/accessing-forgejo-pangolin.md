---
title: "Accessing Forgejo at home through Pangolin"
date: 2025-08-29
draft: false
tags: ["dev", "pangolin", "forgejo"]
categories: ["tutorials"]
description: "Secured access to your Forgejo Git server on your homelab server."
---
Inside your Pangolin Dashboard, add a new resource, write its name, choose *Raw TCP/UDP Resource* and enter *222* as a **TCP** **Port** number.

![pangolin-forgejo-tcp-udp-port.png](/images/posts/pangolin-forgejo-tcp-udp-port_1754053070254_0.png)

Upon creating the resource, Pangolin will tell you how to open the ports through Traefik and Gerbil.

![pangolin-forgejo-configuration-gerbil-traefik.png](/images/posts/pangolin-forgejo-configuration-gerbil-traefik_1754065329949_0.png)

You will need to edit **config/traefik/traefik_config.yml** as superuser and add the following:
  ```yml
    tcp-222:
      address: ":222/tcp"
  ```

Next, edit Pangolin's **docker-compose.yml** and add 222 under Gerbil's ports. Gerbil's configuration should look something like this:
  ```yml
    gerbil:
      image: fosrl/gerbil:1.0.0
      container_name: gerbil
      restart: unless-stopped
      depends_on:
        pangolin:
          condition: service_healthy
      command:
        - --reachableAt=http://gerbil:3003
        - --generateAndSaveKeyTo=/var/config/key
        - --remoteConfig=http://pangolin:3001/api/v1/gerbil/get-config
        - --reportBandwidthTo=http://pangolin:3001/api/v1/gerbil/receive-bandwidth
      volumes:
        - ./config/:/var/config
      cap_add:
        - NET_ADMIN
        - SYS_MODULE
      ports:
        - 51820:51820/udp
        - 443:443 # Port for traefik because of the network_mode
        - 80:80 # Port for traefik because of the network_mode
        - 222:222
  
  ```

![pangolin-forgejo-adding-ip-port.png](/images/posts/pangolin-forgejo-adding-ip-port_1754053670231_0.png) 

Finally, go back to the newly created resource on Pangolin and enter your homelab local IP (xxx.xxx.x.x) and port which is 222 if you have followed this guide.