# docker-minecraft

Standalone Docker-based Minecraft server setup with backups and DNS record
management, primarily for Raspberry Pi 5 with 4+ GB of RAM.

* [Prerequisites](#prerequisites)
* [Customizations](#customizations)
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

## Customizations

For each configured server, the files unique to it are stored in a directory
in `./config`. This allows the project to build and run multiple servers from
the same set of scripts.

Change the server icon, Message of The Day, and more in the `server.properties`
file.

Change the amount of memory allocated in `config.json` to be no more than
75% available on the system.

## Docker build and run

Choose a set of configuration files from `./config` to use when building and
running the server image. For example:

```shell
./scripts/start-docker.sh test
```

Add to crontab to run on boot with `sudo crontab -e`, assuming a location of
`/mnt/ssd/`. Make sure the desired server config is included, such as `test`:

```
@reboot sleep 15 && cd /mnt/ssd/docker-minecraft && ./scripts/start-docker.sh test > /mnt/ssd/docker-minecraft/docker-minecraft.log 2>&1
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

### Local

Backup manually to `docker-minecraft.zip` and copy somewhere safe:

```shell
sudo ./scripts/local-backup.sh $USER $BACKUP_DIR
```

Add the `local-backup.sh` script to crontab to run once a day and copy a file
for each day of the week (7 day rolling backups), for example at 3 AM, to the
`/mnt/ssd/backups` directory:

```
0 3 * * * cd /mnt/ssd/docker-minecraft && ./scripts/local-backup.sh pi hom-mc-server > /mnt/ssd/docker-minecraft/local-backup.log 2>&1
```

### S3 Remote

Upload a backup to an AWS S3 bucket that you have credentials to use:

```shell
sudo ./scripts/upload-backup.sh $USER $SERVER_NAME
```

For example:

```shell
sudo ./scripts/upload-backup.sh pi test
```

Add to crontab for weekly backups (4AM Monday):

```
0 4 * * 1 cd /mnt/ssd/docker-minecraft && ./scripts/upload-backup.sh pi test > /mnt/ssd/docker-minecraft/upload-backup.log 2>&1
```

## DNS

Use the `scripts/update-dns.sh` script to keep a DNS record pointed at the
server's public IP address in case it changes.

Install Node.js via `nvm`:

```shell
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Install node 20
nvm install 20
nvm alias default 20
```

Install node dependencies:

```
npm i
```

Run the monitor with AWS credentials that can update Route53 records, specifying
the subdomain to use:

```shell
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=

./scripts/update-dns.sh $SUBDOMAIN
```

Add to crontab to run the monitor on boot:

```
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=

@reboot sleep 30 && cd /mnt/ssd/docker-minecraft && ./scripts/update-dns.sh minecraft > /mnt/ssd/docker-minecraft/update-dns.log 2>&1
```
