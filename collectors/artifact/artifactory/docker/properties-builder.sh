#!/bin/bash

if [ "$SKIP_PROPERTIES_BUILDER" = true ]; then
  echo "Skipping properties builder"
  exit 0
fi

if [ "$MONGO_PORT" != "" ]; then
	# Sample: MONGO_PORT=tcp://172.17.0.20:27017
	MONGODB_HOST=`echo $MONGO_PORT|sed 's;.*://\([^:]*\):\(.*\);\1;'`
	MONGODB_PORT=`echo $MONGO_PORT|sed 's;.*://\([^:]*\):\(.*\);\2;'`
else
	env
	echo "ERROR: MONGO_PORT not defined"
	exit 1
fi

echo "MONGODB_HOST: $MONGODB_HOST"
echo "MONGODB_PORT: $MONGODB_PORT"


cat > $PROP_FILE <<EOF
#Database Name
dbname=${SPRING_DATA_MONGODB_DATABASE:-dashboarddb}

#Database HostName - default is localhost
dbhost=${MONGODB_HOST:-10.0.1.1}

#Database Port - default is 27017
dbport=${MONGODB_PORT:-27017}

#Database Username - default is blank
dbusername=${SPRING_DATA_MONGODB_USERNAME:-dashboarduser}

#Database Password - default is blank
dbpassword=${SPRING_DATA_MONGODB_PASSWORD:-dbpassword}

#Collector schedule (required)
artifactory.cron=${ARTIFACTORY_CRON:-0 0/5 * * * *}

# Artifact Regex Patterns
# Each artifact found is matched against the following patterns in order (first one wins)
# The following capture groups are available:
#  - group
#  - module
#  - artifact
#  - version
#  - classifier
#  - ext
EOF
idx=0
for x in ${!ARTIFACTORY_PATTERN*}
do
cat >> $PROP_FILE <<EOF
artifactory.patterns[${idx}]=${!x}
EOF
	
	idx=$((idx+1))
done

cat >> $PROP_FILE <<EOF

# Artifactory urls and credentials
EOF

# find how many artifactory urls are configured
max=$(wc -w <<< "${!ARTIFACTORY_URL*}")

# loop over and output the url, username and apiKey
i=0
while [ $i -lt $max ]
do
    if [ $i -eq 0 ]
    then
        server="ARTIFACTORY_URL"
        username="ARTIFACTORY_USERNAME"
        apiKey="ARTIFACTORY_API_KEY"
        repos="ARTIFACTORY_REPO"
        patterns="ARTIFACTORY_PATTERN"
    else
        server="ARTIFACTORY_URL$i"
        username="ARTIFACTORY_USERNAME$i"
        apiKey="ARTIFACTORY_API_KEY$i"
        repos="ARTIFACTORY_REPO$i"
        patterns="ARTIFACTORY_PATTERN$i"
    fi
    
    
cat >> $PROP_FILE <<EOF
artifactory.servers[${i}].url=${!server}
artifactory.servers[${i}].username=${!username}
artifactory.servers[${i}].apiKey=${!apiKey}
artifactory.servers[${i}].repoAndPatterns[0].repo=${!repos}
artifactory.servers[${i}].repoAndPatterns[0].patterns[0]=${!patterns}
EOF
    
    i=$(($i+1))
done

cat >> $PROP_FILE <<EOF

# Artifactory REST endpoint
artifactory.endpoint=${ARTIFACTORY_ENDPOINT:-artifactory/}
artifactory.mode=${ARTIFACTORY_MODE:-ARTIFACT_BASED}
artifactory.offSet=${ARTIFACTORY_OFFSET:-3600000}
EOF

echo "

===========================================
Properties file created `date`:  $PROP_FILE
Note: passwords hidden
===========================================
`cat $PROP_FILE |egrep -vi password`
 "

exit 0
