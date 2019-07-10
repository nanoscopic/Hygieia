#!/bin/bash

cat /tmp/db-setup.js | perl -pe 's/dashboarduser/$ENV{SPRING_DATA_MONGODB_USERNAME}/' | perl -pe 's/dashboardpass/$ENV{SPRING_DATA_MONGODB_PASSWORD}/' > /tmp/db-setup-filled.js
sleep 5s
mongo -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" db/admin --authenticationDatabase=admin < /tmp/db-setup-filled.js