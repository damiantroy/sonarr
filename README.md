# Sonarr TV manager CentOS container

This is a CentOS 8 container for [Sonarr](https://sonarr.tv/), which keeps track of and organises your TV video library.

## Building

To build and test the image, run:

```shell script
make all # build test
```

## Running

More complete instructions are in my [VideoBot Tutorial](https://github.com/damiantroy/videobot),
but this should be enough to get you started.

### Configuration

| Command | Config   | Description
| ------- | -------- | -----
| ENV     | PUID     | UID of the runtime user (Default: 1001)
| ENV     | PGID     | GID of the runtime group (Default: 1001)
| ENV     | TZ       | Timezone (Default: Australia/Melbourne)
| VOLUME  | /videos  | Videos directory, including 'downloads/'
| VOLUME  | /config  | Configuration directory
| EXPOSE  | 8112/tcp | HTTP port for web interface

```shell script
PUID=1001
PGID=1001
TZ=Australia/Melbourne
VIDEOS_DIR=/videos
SONARR_CONFIG_DIR=/etc/sonarr
SONARR_IMAGE=localhost/sonarr # Or damiantroy/sonarr if deploying from docker.io

sudo mkdir -p "$VIDEOS_DIR" "$SONARR_CONFIG_DIR"
sudo chown -R "$PUID:$PGID" "$VIDEOS_DIR" "$SONARR_CONFIG_DIR"

sudo podman run -d \
    --name=sonarr \
    --network=host \
    -e PUID="$PUID" \
    -e PGID="$PGID" \
    -e TZ="$TZ" \
    -v "$SONARR_CONFIG_DIR:/config:Z" \
    -v "$VIDEOS_DIR:/videos:z" \
    "$SONARR_IMAGE"
```
