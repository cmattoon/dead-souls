cmattoon/deadsouls
==================

Dockerized version of [dead-souls](http://dead-souls.net) MUD library.

Available tags:

    $ docker pull cmattoon/deadsouls:v3.8.2
    $ docker pull cmattoon/deadsouls:v3.9

TL;DR

    $ docker-compose up


Configuration
-------------

If no configuration file is specified, `entrypoint.sh` will attempt to template `files/mudos.tpl` from environment vars.
See `files/entrypoint.sh` and `files/mudos.tpl` for a full list of environment vars.

It's just as easy to mount your own config file (see `docker-compose.yml` for an example):

  * Default config inside container: `DS_CONFIG_FILE=/opt/deadsouls/config/mudos.cfg`
  * For best results, mount `$LOCAL_CONFIG_DIR:/opt/deadsouls/config`

Theoretically, any mount path can be used, but those directories are created and owned by the unprivileged OS user.
If you mount somewhere else, the volume may be owned by `root` and require workarounds, like `chmod` on the host.

  * State is saved in the `lib` directory, so you probably want to mount that, too.
  * Option 1: Mount `/opt/deadsouls/lib` to overwrite the default `lib` directory
  * Option 2: Mount `/opt/deadsouls/custom-lib` and update the config to use this new directory


Custom Docker Image
-------------------

You can extend this Docker image very easily by simply copying your lib directory:

```Dockerfile
FROM cmattoon/dead-souls:v3.9

WORKDIR /opt/deadsouls

COPY my-repo/lib /opt/deadsouls/my-lib

COPY my-repo/mudos.cfg /opt/deadsouls/config/mudos.cfg
```

### Change Volumes

To make (e.g.) `/opt/deadsouls/custom-lib/secure` a volume that the `deadsouls` unprivileged user can use:

```
USER root
RUN mkdir -p /opt/deadsouls/custom-lib/secure && chown -R deadsouls:deadsouls /opt/deadsouls
USER deadsouls
VOLUME ["/opt/deadsouls/custom-lib/secure"]
```

