#!/bin/bash

FLAG="/firstboot.log"

if [[ ! -f $FLAG ]]; then
   sleep 10

   echo BUILDING RD DATABASE ...

   echo -- CONFIGURE TIME ZONES
   mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql

   sleep 10

   echo -- CONFIGURE PRIVELEGES
   mysql -u root < /tmp/db_priveleges.sql

   sleep 2

   echo -- IMPORT RADIUSDESK BASE TABLES
   mysql -u root rd < /tmp/rd.sql

   echo -- APPLY RADIUSDESK MAIN MYSQL MIGRATIONS
   for migration in /tmp/8.*.sql; do
      if [ -f "$migration" ]; then
         echo "Applying $migration"
         mysql -u root rd < "$migration" || exit 1
      fi
   done

   echo -- APPLY RADIUSDESK OPTIONAL MYSQL MIGRATIONS
   for migration in /tmp/2.*.sql; do
      if [ -f "$migration" ]; then
         echo "Applying $migration"
         mysql -u root rd < "$migration" || exit 1
      fi
   done

   echo -- APPLY RADIUSDESK MYSQL SHARDING MIGRATIONS
   for migration in /tmp/9.*.sql; do
      if [ -f "$migration" ]; then
         echo "Applying $migration"
         mysql -u root rd < "$migration" || exit 1
      fi
   done

   touch "$FLAG"

   echo COMPLETED DATABASE BUILD ...
fi
