# docker-minecraft

Standalone Docker-based Minecraft server setup with backups and DNS record
management, primarily for Raspberry Pi 5 with 4+ GB of RAM.

* [Prerequisites](#prerequisites)
* [Docker build and run](#docker-build-and-run)
* [Stopping the server](#stopping-the-server)
* [Backups](#backups)
* [DNS](#dns)

## Prerequisites

1. Install this repo to a fast SSD located at `/mnt/ssd`.

2. Install Docker and add the user to the docker group:

```
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker $USER
logout
```

## Docker build and run

```
./scripts/start-docker.sh
```

Add to crontab to run on boot with `sudo crontab -e`, assuming a location of
`/mnt/ssd/`:

```
@reboot sleep 15 && cd /mnt/ssd/docker-minecraft && ./scripts/start-docker.sh > /mnt/ssd/docker-minecraft/docker-minecraft.log 2>&1
```

## Stopping the server

To safely stop the server, log in as an Op user and run the `/exit` command.

If not possible, force-stop the container:

```
docker ps
```

With the container ID:

```
docker stop $CONTAINER_ID
```

## Backups

Backup manually to `docker-minecraft.zip`:

```
sudo ./scripts/create-zip.sh $USER
```

Add the `local-backup.sh` script to crontab to run once a day and copy a file
for each day of the week (7 day rolling backups), for example at 3 AM:

```
0 3 * * * cd /mnt/ssd/docker-minecraft && ./scripts/local-backup.sh > /mnt/ssd/docker-minecraft/local-backup.log 2>&1
```

## DNS
