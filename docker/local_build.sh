#!/bin/bash

set -xu

source ./.env

docker network inspect "$RADIUSDESK_NETWORK" >/dev/null 2>&1 || \
docker network create --attachable -d bridge "$RADIUSDESK_NETWORK" || exit 1

echo Radiusdesk 2-docker system builder v1.0
echo ---------------------------------------
echo
echo Starting Build ....
echo
echo Copying database files to volume mounts for MariaDB ...

mkdir -p "$RADIUSDESK_VOLUME" || exit 1
mkdir -p "$RADIUSDESK_VOLUME/db_startup" || exit 1
mkdir -p "$RADIUSDESK_VOLUME/db_conf" || exit 1

chmod -R 777 "$RADIUSDESK_VOLUME" || exit 1
chmod -R 777 "$RADIUSDESK_VOLUME/db_startup" || exit 1
chmod -R 777 "$RADIUSDESK_VOLUME/db_conf" || exit 1

if [ -d "rdcore" ]
then
    echo "Nested docker/rdcore directory exists but is no longer used."
fi

cp ../cake4/rd_cake/setup/db/rd.sql "$RADIUSDESK_VOLUME/db_startup/" || exit 1
cp ../cake4/rd_cake/setup/db/8.*.sql "$RADIUSDESK_VOLUME/db_startup/" || exit 1
cp ../cake4/rd_cake/setup/db/optional/*.sql "$RADIUSDESK_VOLUME/db_startup/" || exit 1
cp ../cake4/rd_cake/setup/db/mysql_sharding/*.sql "$RADIUSDESK_VOLUME/db_startup/" || exit 1

cp db_priveleges.sql "$RADIUSDESK_VOLUME/db_startup/" || exit 1
cp startup.sh "$RADIUSDESK_VOLUME/db_startup/" || exit 1
cp my_custom.cnf "$RADIUSDESK_VOLUME/db_conf/" || exit 1

echo
echo Building docker database container ...
docker-compose up -d rdmariadb || exit 1

echo
echo Waiting for MariaDB to come up ...
sleep 60

echo Creating database for Radiusdesk ...
docker exec -u 0 -it radiusdesk-mariadb /tmp/startup.sh || exit 1

echo
echo Building Radiusdesk container with nginx, php-fpm and freeradius ...

docker-compose build || exit 1
docker-compose up -d radiusdesk || exit 1

echo
echo All done!
