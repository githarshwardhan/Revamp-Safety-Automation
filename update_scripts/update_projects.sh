#!/bin/bash

 read -p "Enter Git Tag for projects:" GITTAG


for PROJECT_Directory_NAME in "ANP_Ultimus" "ANP_Memento"; do
#    read -p "Enter Git Tag for $PROJECT_NAME:" GITTAG
    export GITTAG
    export PROJECT_Directory_NAME

    cd /opt/build/project-build/safety-revamp-${PROJECT_Directory_NAME}-build

    rm -r vsa-revamp-project
    git clone -b ${GITTAG} https://aniketb:rXsbnGcJGpfbcqyDYxvT@gitlab.valueaddsofttech.com/safetyrevamp/vsa-revamp-project.git

    cd vsa-revamp-project

    GIT_TAG=$(cat version.txt | tr -d '\n')

    cd ..

    # Check if the Docker image exists
    if docker image inspect project:$GIT_TAG &> /dev/null; then
        echo "Docker image project:$GIT_TAG exists."
    else
        echo "Docker image project:$GIT_TAG not exist. Building..."
        docker build -t project:$GIT_TAG .
    fi

    sed -i "s/^export revampvsa_image=.*/export revampvsa_image=\"project:$GIT_TAG\"/" /opt/deploy/project-deploy/safety-revamp-${PROJECT_Directory_NAME}-deploy/env.sh

    cd /opt/deploy/project-deploy/safety-revamp-${PROJECT_Directory_NAME}-deploy

    chmod +x env.sh
    source /opt/deploy/project-deploy/safety-revamp-${PROJECT_Directory_NAME}-deploy/env.sh

    docker stack rm ${PROJECT_Directory_NAME}
    sleep 15
    docker stack deploy -c docker-compose.yml ${PROJECT_Directory_NAME}
done

