---
title: "Easy simple Django Wagtail Docker Container"
date: 2025-08-16
draft: false
tags: ["dev", "docker", "django", "wagtail", "postgresql"]
categories: ["tutorials"]
description: "Creating a geospatial database and using it with Django/Wagtail."
---
Here is a tutorial to to create a geospatial app using Wagtail (alongside Geodjango) and PostgreSQL extension PostGIS so that you can create objects using latitude/longitude coordinates or the map inside the admin site.

Code and folder hierarchy [available on GitHub](https://github.com/CacteGra/wagtail-location-map-docker).

Create a directory for the whole project:
  `mkdir mysite_whole`  
  
Create a virtual environment as no to pollute your local machine with version control issues, that way we can peacefully install Django locally.
  `virtualenv -p python3 venv`  
  We are making a virtual environment using *Python 3* which will be stored inside *venv* folder.  
  Let's activate it:  
  `source venv/bin/activate`  
  
Then we install Wagtail CMS, Django is also part of the installation process:
  `pip install wagtail`  
  
Create our Wagtail site's folder then let Wagtail generate the site:
```bash
  mkdir mysite
  wagtail start mysite mysite
```

Install the dependencies making sure you already have everything to run Wagtail:
```bash
  cd mysite
  pip install -r requirements.txt
```

Locally we may only need to use SQLite, at first anyway, so we need to match our models developed inside Django/Wagtail to our database. To do so, run the following command:
id:: 68877b48-32a3-4b93-b6ef-87a3a10ae32a
  `python manage.py migrate`  
  This command will be extremely important as you make changes to your models and need to update your dev/production site running inside a Docker container so that restart the container, Django will know to make database migrations.  
  
Now onto creating an admin user so we can run, serve and manage our website:
  `python manage.py createsuperuser`  
  Enter a **username**, **email address** and **password**.  
  Launch your site:  
  `python manage.py runserver`  
  You can check it out at: http://127.0.0.1:8000/  
  
You website is functional albeit only locally.
:logbook:
  CLOCK: [2025-08-04 Mon 10:18:05]
  CLOCK: [2025-08-04 Mon 10:18:07]
:END:
  A Dockerfile will allow us to run our installation inside a virtual container. And you might notice a file named *Dockerfile* already exists inside *mysite* folder. Perfect! We can already server our website using the following commands.  
  First we build our container named easy_django_wagtail:  
  `docker build . -t mysite/backend`  
  Then we spin up the container and hook it on port 8000 so it is accessible through this port as specified in the Dockerfile.  
  `docker run -p 8001:8000 mysite/backend`  
  
In order to create a super user to log into the admin interface, you first need to know the ID of your wagtail container.
  `docker container ps`  
  Should display this table:  
  
| CONTAINER ID | IMAGE | COMMAND | CREATED | STATUS | PORTS | NAMES |
|---|---|---|---|---|---|---|
| container_id | easy_django_wagtail_test | "/bin/sh -c 'set -xe…" | 2 minutes ago | Up 2 minutes | 0.0.0.0:8000->8000/tcp, [::]:8000->8000/tcp | random_name |

Then:  
`docker exec -it container_id python manage.py createsuperuser`  
Write your **username**, **email address** and **password**.  
To shut it off:  
`docker stop container_id`  
  
We could use it as such, changing ports to match port 80; Let's Encrypt even has [six-day SSL certificates for IP addresses](https://letsencrypt.org/2025/01/16/6-day-and-ip-certs/).

For a better running Wagtail install, we are going to add a few modifications to our project. We will use Caddy to serve our site through a reverse proxy and get a SSL certificate for our domain with Let's Encrypt in a future article. Right now we are looking to run the overall project with a **Docker Compose** instance, so that database migrations to follow model changes and local tests can easily be done using our local virtual environment and *python manage.py* commands.

## Running the project with Docker Compose

An entrypoint will help us move from a dev to a production setting, inside **mysite/**:
  `nano docker-entrypoint.sh`  
  
```bash
  #!/bin/sh
  # docker-entrypoint.sh
  
  if test -f "$FILE"; then
    echo 'Start removed manage added prod'
    rm manage.py && mv manage.production.py manage.py
    rm mysite/wsgi.py && mv mysite/wsgi.production.py mysite/wsgi.py
  fi
  
  python manage.py makemigrations --noinput
  python manage.py migrate --noinput
  python manage.py collectstatic --noinput
  # Launch the main container command passed as arguments.
  exec "$@"
```
  Make the entrypoint executable:  
  `chmod +x docker-entrypoint.sh`  
  Add the command to your **Dockerfile**:  
  `ENTRYPOINT ["./docker-entrypoint.sh"]`  
  And remove commands now deemed unnecessary:  
  
```Dockerfile
  RUN python manage.py collectstatic --noinput --clear
  # And
  CMD set -xe; python manage.py migrate --noinput; gunicorn mysite.wsgi:application
```

We create a **start.sh** file that will run our project in production setting when needed; to do so, the executable will replace our base **manage.py** and **wsgi.py** with **manage.production.py** which will tell Django to use **mysite/mysite/production.py** and **wsgi.production.py** respectively. For now though, we'll set **manage.production.py** as *.pynone extensions so as not to trigger the boolean condition to set our environment as production.
  **start.sh**  
  
```bash
  FILE=manage.production.py
  if test -f "$FILE"; then
  echo 'Start removed manage added prod'
  rm manage.py && mv manage.production.py manage.py
  rm mysite/wsgi.py && mv mysite/wsgi.production.py mysite/wsgi.py
  fi
  python manage.py makemigrations --noinput
  python manage.py migrate --noinput
  python manage.py collectstatic --noinput
  gunicorn mysite.wsgi:application
```
  Then create **manage.production.pynone**:  
  
```python
  #!/usr/bin/env python
  import os
  import sys
  
  if __name__ == "__main__":
      os.environ.setdefault("DJANGO_SETTINGS_MODULE", "mysite.settings.production")
  
      from django.core.management import execute_from_command_line
  
      execute_from_command_line(sys.argv)
```
  And finally **mysite/wsgi.production.py**:  
  
```python
  """
  WSGI config for trashitcd  project.
  
  It exposes the WSGI callable as a module-level variable named ``application``.
  
  For more information on this file, see
  https://docs.djangoproject.com/en/3.1/howto/deployment/wsgi/
  """
  
  import os
  
  from django.core.wsgi import get_wsgi_application
  
  os.environ.setdefault("DJANGO_SETTINGS_MODULE", "mysite.settings.production")
  
  application = get_wsgi_application()
```

Create a **docker-compose.yml** file in the root directory **mysite_whole** of your install:
```docker-compose
  services:
    backend:
      build:
        context: mysite/
      restart: always
      image: mysite/backend
      ports:
        - "800:8000"
      entrypoint: ["/bin/sh","-c"]
      command:
      - |
         ./start.sh
      networks:
        - mysite-backend
      volumes:
        - static:/app/static
        - media:/app/media
        - private:/app/private
  networks:
    mysite-backend:
      driver: bridge
  volumes:
      static:
        driver: local
      media:
        driver: local
      private:
        driver: local
  
```

Build your Dockerfile project:
  `docker build . -t mysite/backend`  
  And then launch Docker Compose with:  
  `docker compose up`  
  You will have to recreate your **admin login** this time using Docker Compose:  
  `docker compose exec backend python manage.py createsuperuser`  
  
Go to `127.0.0.1:8001`, login, then Snippets and add a location object and you either enter latitude/longitude coordinates or drag the pin to the desired location.

## Using Postgres-based Postgis geospatial database

We are going ahead with preparing our site to use a geospatial database: **PostGIS**.
  First, inside Dockerfile make a few changes:  
  `nano Dockerfile`  
  
Add the following to system packages:
```Dockerfile
      gdal-bin \
      libgdal-dev \
      python3-gdal \
```
  So Dockerfile should look like this:  
  
```dockerfile
  # Use an official Python runtime based on Debian 12 "bookworm" as a parent image.
  FROM python:3.12-slim-bookworm
  
  # Add user that will be used in the container.
  RUN useradd wagtail
  
  # Port used by this container to serve HTTP.
  EXPOSE 8000
  
  # Set environment variables.
  # 1. Force Python stdout and stderr streams to be unbuffered.
  # 2. Set PORT variable that is used by Gunicorn. This should match "EXPOSE"
  #    command.
  ENV PYTHONUNBUFFERED=1 \
      PORT=8000
  
  # Install system packages required by Wagtail and Django.
  RUN apt-get update --yes --quiet && apt-get install --yes --quiet --no-install-recommends \
      build-essential \
      libpq-dev \
      libmariadb-dev \
      libjpeg62-turbo-dev \
      zlib1g-dev \
      libwebp-dev \
      gdal-bin \
      libgdal-dev \
      python3-gdal \
   && rm -rf /var/lib/apt/lists/*
  
  # Install the application server.
  RUN pip install "gunicorn==20.0.4"
  
  # Install the project requirements.
  COPY requirements.txt /
  RUN pip install -r /requirements.txt
  
  # Use /app folder as a directory where the source code is stored.
  WORKDIR /app
  
  # Set this directory to be owned by the "wagtail" user. This Wagtail project
  # uses SQLite, the folder needs to be owned by the user that
  # will be writing to the database file.
  RUN chown wagtail:wagtail /app
  
  # Copy the source code of the project into the container.
  COPY --chown=wagtail:wagtail . .
  
  # Use user "wagtail" to run the build commands below and the server itself.
  USER wagtail
  
  ENTRYPOINT ["./docker-entrypoint.sh"]             # must be JSON-array syntax
```

It is also necessary to add *psycopg2* module to **requirements.txt** which has been created during our initial wagtail site install in order to use the PostGIS database. We take this opportunity to add **wagtaileowidget**, will help us display a map field when managing objects inside the admin site:
```txt
  psycopg2
  wagtailgeowidget==8.2.1
```

In the file **mysite/mysite/settings/base.py**, add modules *django.contrib.gis* and *wagtailgeowidget* to **INSTALLED_APPS** so it should look like this:
```python
  INSTALLED_APPS = [
      "home",
      "search",
      "wagtail.contrib.forms",
      "wagtail.contrib.redirects",
      "wagtail.embeds",
      "wagtail.sites",
      "wagtail.users",
      "wagtail.snippets",
      "wagtail.documents",
      "wagtail.images",
      "wagtail.search",
      "wagtail.admin",
      "wagtail",
      "modelcluster",
      "taggit",
      "django_filters",
      "django.contrib.admin",
      "django.contrib.auth",
      "django.contrib.contenttypes",
      "django.contrib.sessions",
      "django.contrib.messages",
      "django.contrib.staticfiles",
      "django.contrib.gis",
      "wagtailgeowidget",
  ]
```

Inside **mysite/mysite/settings/dev.py**, tell Django/Wagtail set the default database parameters as environment variables to switch between SQLite and PostgreSQL databases. We also include Wagtail admin base url:
```python
  from .base import *
  
  DEBUG = True
  
  # SECURITY WARNING: keep the secret key used in production secret!
  SECRET_KEY = "django-insecure-secret-key"
  
  # SECURITY WARNING: define the correct hosts in production!
  ALLOWED_HOSTS = ["*"]
  
  EMAIL_BACKEND = "django.core.mail.backends.console.EmailBackend"
  
  DATABASES = {
      'default': {
          'ENGINE': os.environ.get('DB_ENGINE', 'django.db.backends.sqlite3'),
          'NAME': os.environ.get('POSTGRES_DB', 'db.sqlite3'),
          'USER': os.environ.get('POSTGRES_USER', 'dbuser'),
          'PASSWORD': os.environ.get('POSTGRES_PASSWORD', 'dbpasswd'),
          'HOST': 'db',
          'PORT': '5433',
      }
  }
  
  WAGTAILADMIN_BASE_URL = os.environ.get('WAGTAILADMIN_BASE_URL', '127.0.0.1')
  
  try:
      from .local import *
  except ImportError:
      pass
  
```

We need to create a file for our backend service to wait for the database to be ready, *wait-for-it.sh*, then start it by executing *start.sh*.
  **wait-for-it.sh**  
  
```bash
  #!/usr/bin/env bash
  # Use this script to test if a given TCP host/port are available
  
  WAITFORIT_cmdname=${0##*/}
  
  echoerr() { if [[ $WAITFORIT_QUIET -ne 1 ]]; then echo "$@" 1>&2; fi }
  
  usage()
  {
      cat << USAGE >&2
  Usage:
      $WAITFORIT_cmdname host:port [-s] [-t timeout] [-- command args]
      -h HOST | --host=HOST       Host or IP under test
      -p PORT | --port=PORT       TCP port under test
                                  Alternatively, you specify the host and port as host:port
      -s | --strict               Only execute subcommand if the test succeeds
      -q | --quiet                Don't output any status messages
      -t TIMEOUT | --timeout=TIMEOUT
                                  Timeout in seconds, zero for no timeout
      -- COMMAND ARGS             Execute command with args after the test finishes
  USAGE
      exit 1
  }
  
  wait_for()
  {
      if [[ $WAITFORIT_TIMEOUT -gt 0 ]]; then
          echoerr "$WAITFORIT_cmdname: waiting $WAITFORIT_TIMEOUT seconds for $WAITFORIT_HOST:$WAITFORIT_PORT"
      else
          echoerr "$WAITFORIT_cmdname: waiting for $WAITFORIT_HOST:$WAITFORIT_PORT without a timeout"
      fi
      WAITFORIT_start_ts=$(date +%s)
      while :
      do
          if [[ $WAITFORIT_ISBUSY -eq 1 ]]; then
              nc -z $WAITFORIT_HOST $WAITFORIT_PORT
              WAITFORIT_result=$?
          else
              (echo -n > /dev/tcp/$WAITFORIT_HOST/$WAITFORIT_PORT) >/dev/null 2>&1
              WAITFORIT_result=$?
          fi
          if [[ $WAITFORIT_result -eq 0 ]]; then
              WAITFORIT_end_ts=$(date +%s)
              echoerr "$WAITFORIT_cmdname: $WAITFORIT_HOST:$WAITFORIT_PORT is available after $((WAITFORIT_end_ts - WAITFORIT_start_ts)) seconds"
              break
          fi
          sleep 1
      done
      return $WAITFORIT_result
  }
  
  wait_for_wrapper()
  {
      # In order to support SIGINT during timeout: http://unix.stackexchange.com/a/57692
      if [[ $WAITFORIT_QUIET -eq 1 ]]; then
          timeout $WAITFORIT_BUSYTIMEFLAG $WAITFORIT_TIMEOUT $0 --quiet --child --host=$WAITFORIT_HOST --port=$WAITFORIT_PORT --timeout=$WAITFORIT_TIMEOUT &
      else
          timeout $WAITFORIT_BUSYTIMEFLAG $WAITFORIT_TIMEOUT $0 --child --host=$WAITFORIT_HOST --port=$WAITFORIT_PORT --timeout=$WAITFORIT_TIMEOUT &
      fi
      WAITFORIT_PID=$!
      trap "kill -INT -$WAITFORIT_PID" INT
      wait $WAITFORIT_PID
      WAITFORIT_RESULT=$?
      if [[ $WAITFORIT_RESULT -ne 0 ]]; then
          echoerr "$WAITFORIT_cmdname: timeout occurred after waiting $WAITFORIT_TIMEOUT seconds for $WAITFORIT_HOST:$WAITFORIT_PORT"
      fi
      return $WAITFORIT_RESULT
  }
  
  # process arguments
  while [[ $# -gt 0 ]]
  do
      case "$1" in
          *:* )
          WAITFORIT_hostport=(${1//:/ })
          WAITFORIT_HOST=${WAITFORIT_hostport[0]}
          WAITFORIT_PORT=${WAITFORIT_hostport[1]}
          shift 1
          ;;
          --child)
          WAITFORIT_CHILD=1
          shift 1
          ;;
          -q | --quiet)
          WAITFORIT_QUIET=1
          shift 1
          ;;
          -s | --strict)
          WAITFORIT_STRICT=1
          shift 1
          ;;
          -h)
          WAITFORIT_HOST="$2"
          if [[ $WAITFORIT_HOST == "" ]]; then break; fi
          shift 2
          ;;
          --host=*)
          WAITFORIT_HOST="${1#*=}"
          shift 1
          ;;
          -p)
          WAITFORIT_PORT="$2"
          if [[ $WAITFORIT_PORT == "" ]]; then break; fi
          shift 2
          ;;
          --port=*)
          WAITFORIT_PORT="${1#*=}"
          shift 1
          ;;
          -t)
          WAITFORIT_TIMEOUT="$2"
          if [[ $WAITFORIT_TIMEOUT == "" ]]; then break; fi
          shift 2
          ;;
          --timeout=*)
          WAITFORIT_TIMEOUT="${1#*=}"
          shift 1
          ;;
          --)
          shift
          WAITFORIT_CLI=("$@")
          break
          ;;
          --help)
          usage
          ;;
          *)
          echoerr "Unknown argument: $1"
          usage
          ;;
      esac
  done
  
  if [[ "$WAITFORIT_HOST" == "" || "$WAITFORIT_PORT" == "" ]]; then
      echoerr "Error: you need to provide a host and port to test."
      usage
  fi
  
  WAITFORIT_TIMEOUT=${WAITFORIT_TIMEOUT:-15}
  WAITFORIT_STRICT=${WAITFORIT_STRICT:-0}
  WAITFORIT_CHILD=${WAITFORIT_CHILD:-0}
  WAITFORIT_QUIET=${WAITFORIT_QUIET:-0}
  
  # Check to see if timeout is from busybox?
  WAITFORIT_TIMEOUT_PATH=$(type -p timeout)
  WAITFORIT_TIMEOUT_PATH=$(realpath $WAITFORIT_TIMEOUT_PATH 2>/dev/null || readlink -f $WAITFORIT_TIMEOUT_PATH)
  
  WAITFORIT_BUSYTIMEFLAG=""
  if [[ $WAITFORIT_TIMEOUT_PATH =~ "busybox" ]]; then
      WAITFORIT_ISBUSY=1
      # Check if busybox timeout uses -t flag
      # (recent Alpine versions don't support -t anymore)
      if timeout &>/dev/stdout | grep -q -e '-t '; then
          WAITFORIT_BUSYTIMEFLAG="-t"
      fi
  else
      WAITFORIT_ISBUSY=0
  fi
  
  if [[ $WAITFORIT_CHILD -gt 0 ]]; then
      wait_for
      WAITFORIT_RESULT=$?
      exit $WAITFORIT_RESULT
  else
      if [[ $WAITFORIT_TIMEOUT -gt 0 ]]; then
          wait_for_wrapper
          WAITFORIT_RESULT=$?
      else
          wait_for
          WAITFORIT_RESULT=$?
      fi
  fi
  
  if [[ $WAITFORIT_CLI != "" ]]; then
      if [[ $WAITFORIT_RESULT -ne 0 && $WAITFORIT_STRICT -eq 1 ]]; then
          echoerr "$WAITFORIT_cmdname: strict mode, refusing to execute subprocess"
          exit $WAITFORIT_RESULT
      fi
      exec "${WAITFORIT_CLI[@]}"
  else
      exit $WAITFORIT_RESULT
  fi
```
  Again, make the file executable:  
  `chmod +x wait-for-it.sh`  
  
Now we prepare **docker-compose.yaml**, adding our Postgres database service, and filling in environment variables used both by PostgrSQL/PostGIS and Django/Wagtail. We'll later see that environment variables set in an **.env** file will take precedence over the default ones when setting up our project to be production-ready.
```docker-compose
  services:
    backend:
      build:
        context: mysite/
      restart: always
      image: mysite/backend
      ports:
        - "8001:8000"
      entrypoint: ["/bin/sh","-c"]
      command:
      - |
         ./wait-for-it.sh db:5433 -- ./start.sh
      environment:
        - DB_ENGINE=${DB_ENGINE:-django.contrib.gis.db.backends.postgis}
        - POSTGRES_DB=${POSTGRES_DB:-dbname}
        - POSTGRES_USER=${POSTGRES_DB:-dbuser}
        - POSTGRES_PASSWORD=${POSTGRES_DB:-dbpasswd}
      networks:
        - mysite-backend
      volumes:
        - static:/app/static
        - media:/app/media
        - private:/app/private
    db:
      restart: always
      image: postgis/postgis:latest
      ports:
        - "127.0.0.1:5433:5433"
      networks:
        - mysite-backend
      environment:
        - POSTGRES_DB=${POSTGRES_DB:-dbname}
        - POSTGRES_USER=${POSTGRES_DB:-dbuser}
        - POSTGRES_PASSWORD=${POSTGRES_DB:-dbpasswd}
      command: -p 5433
  networks:
    mysite-backend:
      driver: bridge
  volumes:
      static:
        driver: local
      media:
        driver: local
      private:
        driver: local
```

Rebuild mysite:
  `docker build . -t mysite/backend`  
  Then launch the Docker Compose instance to test out the configuration and PostgreSQL:  
  `docker compose up`  
  
Open another terminal and create your super user for this container's Wagtail using Docker Compose:
  `docker compose exec backend python manage.py createsuperuser`  
  
## Creating a location-based admin map

In order to test our geospatial database, we are going to create our first model that includes a point field and create a point object in the admin site.
  To do so, we create a new application using:  
  `python manage.py startapp maps`  
  You will have to add this new app to the base settings **base.py INSTALLED_APPS**:  
  `    "maps",`  
  Inside **mysite/maps/** you should find a **models.py** file, this is where we declare our database schema.  
  `nano mysite/maps/models.py`  
  
```python
  # Replace from django.db import models with the next line
  # so that we use geodjango models
  from django.contrib.gis.db import models
  
  # Create your models here.
  
  class Location(models.Model):
      location_name = models.CharField(max_length=50)
      location = models.PointField(srid=4326)
```

Here is when making modifications to your database models you should not forget to migrate the changes and apply them.
  `python manage.py migrate && python manage.py makemigrations`  
  
Wagtail is primarily on being CMS to provide a better interface and workflow than basic Django. Therefore we need to tell our site we are going to use our own models in the admin interface.
  Create a file *wagtail_hooks.py* right beside **models.py** inside our maps app folder:  
  `nano wagtail_hooks.py`  
  
```python
  from wagtail.snippets.models import register_snippet
  from wagtail.snippets.views.snippets import SnippetViewSet
  from wagtail.admin.panels import FieldPanel
  from wagtailgeowidget.panels import LeafletPanel
  
  from .models import Location
  
  class LocationTemplate(SnippetViewSet):
      model = Location
  
      panels = [
          # Here is defined which fields are displayed
         	# and what panel type is used to display them
          FieldPanel("location_name"),
          LeafletPanel("location"),
      ]
      
  register_snippet(LocationTemplate)
```

Go to `127.0.0.1:8001`, login, then Snippets and add a location object and you either enter latitude/longitude coordinates or drag the pin to the desired location.
