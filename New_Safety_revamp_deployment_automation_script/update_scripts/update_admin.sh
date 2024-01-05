#!/bin/bash

read -p "Enter Git Tag:" GITTAG
export GITTAG

cd /opt/build/admin-build/safety-revamp-admin-build/
rm -r vsa-revamp-admin

git clone -b $GITTAG https://aniketb:rXsbnGcJGpfbcqyDYxvT@gitlab.valueaddsofttech.com/safetyrevamp/vsa-revamp-admin.git

######create docker image############
cd vsa-revamp-admin

GIT_TAG=$(cat version.txt | tr -d '\n')

cd ..

# Check if the Docker image exists
if docker image inspect admin:$GIT_TAG &> /dev/null; then
    echo "Docker image admin:$GIT_TAG exists."
else
    echo "Docker image admin:$GIT_TAG not exist. Building..."
    docker build -t admin:$GIT_TAG .
fi

sed -i "s/^export revampvsa_image=.*/export revampvsa_image=\"admin:$GIT_TAG\"/" /opt/deploy/admin-deploy/safety-revamp-admin-deploy/env.sh

cd /opt/deploy/admin-deploy/safety-revamp-admin-deploy/
chmod +x env.sh
source env.sh

docker stack rm admin
sleep 15
docker stack deploy -c docker-compose.yml admin
