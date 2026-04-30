# RdCore (Docker Setup)

This repository provides a Docker-based setup for:
- RadiusDesk UI/API (CakePHP 4 + ExtJS)
- FreeRADIUS 3.x
- MariaDB

## System Requirements
- Host OS: Ubuntu 24.04 (tested)
- Docker Engine + Docker Compose installed
- Port `80` available on your host

## First-Time Setup (Bootstrap DB + Start Containers)
```bash
git clone https://github.com/routerarchitects/rdcore.git
cd rdcore
git checkout cake4

cd docker
sudo ./local_build.sh
```

Open the UI:
```text
http://<your-host-ip>/
```

## After Code Changes (Fast Dev Loop)

You do **not** need to re-run `local_build.sh` for normal changes.

Rebuild and recreate only the `radiusdesk` container:
```bash
cd docker
docker compose build radiusdesk
docker compose up -d --force-recreate radiusdesk
```

## Useful Commands
```bash
cd docker
docker compose ps
docker logs -f radiusdesk
docker logs -f radiusdesk-mariadb
```

## Resetting The Database (Optional)

Only do this if you intentionally want a fresh DB.

1. Stop containers: `cd docker && docker compose down`
2. Delete the DB volume folder configured in `docker/.env` (`RADIUSDESK_VOLUME`)
3. Run `cd docker && sudo ./local_build.sh` again

