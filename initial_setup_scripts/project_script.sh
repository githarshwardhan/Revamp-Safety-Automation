#!/bin/bash
######${DB_NAME} CREATION######
mongosh --host localhost --port 27017 -u adminuser -p safetyapp2024 --authenticationDatabase admin <<EOF
use ${DB_NAME}
db.createUser({user: "${DB_USER}",pwd: '${DB_PASSWD}', roles: [ { role: "dbOwner", db: "${DB_NAME}" } ]})

EOF

CURRENT_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
# Run the MongoDB query and store the result in a variable
RESULT=$(mongosh --host localhost --port 27017 -u adminuser -p safetyapp2024 --authenticationDatabase admin --quiet --eval "db.projects.find({ 'projectName': '$PROJECT_NAME' }).count()" $DB_NAME)

# Check if the document count is greater than 0
if [ "$RESULT" -gt 0 ]; then
  echo "Document exists in the collection."
else
  echo "Document does not exist in the collection."
  mongosh --host localhost --port 27017 -u adminuser -p safetyapp2024 --authenticationDatabase admin <<EOF
  use $DB_NAME
  db.projects.insert({"status":"Active","projectName":"${PROJECT_NAME}","projectCode":"${PROJECT_CODE}","zoneName":"${ZONE_NAME}","city":"${CITY}","contactNumber":"${CONTACT_NUMBER}","address":"${ADDRESS}","numberofBuildings":${NUMBER_OF_BUILDINGS},"createdAt":ISODate("${CURRENT_DATE}")
})

EOF
fi

####################################################
#Add project to safetyappadmin database
CHECK=$(mongosh --host localhost --port 27017 -u adminuser -p safetyapp2024 --authenticationDatabase admin --quiet --eval "db.projects.find({ 'projectName': '$PROJECT_NAME' }).count()" clientadmindb)

# Check if the document count is greater than 0
if [ "$CHECK" -gt 0 ]; then
  echo "Project exists in the clientadmindb"
else
  echo "Project does not exists in the clientadmindb"
  mongosh --host localhost --port 27017 -u adminuser -p safetyapp2024 --authenticationDatabase admin <<EOF
  use clientadmindb
  db.projects.insert({"projectCode": "${PROJECT_CODE}",projectName:"${PROJECT_NAME}"});
EOF

fi
#########################################################
mkdir -p /opt/build/project-build/safety-revamp-${PROJECT_Directory_NAME}-build
cd /opt/build/project-build/safety-revamp-${PROJECT_Directory_NAME}-build

rm -r vsa-revamp-project
git clone -b ${GITTAG}  https://token:AhaQ2ovu_4AUe8d1MQPm@gitlab.valueaddsofttech.com/safetyrevamp/vsa-revamp-admin.git

mongoimport --db ${DB_NAME} --host localhost --port 27017 --username ${DB_USER} --password ${DB_PASSWD} --collection configurationtypes --type json --file "vsa-revamp-project/src/scripts/day0/configurationtypes.json"

mongoimport --db ${DB_NAME} --host localhost --port 27017 --username ${DB_USER} --password ${DB_PASSWD} --collection configurations --type json --file "vsa-revamp-project/src/scripts/day0/configurations.json"

########uploads folder for ${DB_NAME}###########
cd /mnt

mkdir -p $PROJECT_Directory_NAME/uploads/project
mkdir -p $PROJECT_Directory_NAME/uploads/inductiontrainings
mkdir -p $PROJECT_Directory_NAME/uploads/inductiontrainings/idproofphotos
mkdir -p $PROJECT_Directory_NAME/uploads/inductiontrainings/photos
mkdir -p $PROJECT_Directory_NAME/uploads/inductiontrainings/signatures
mkdir -p $PROJECT_Directory_NAME/uploads/inductiontrainings/contractorworkorderphotos
mkdir -p $PROJECT_Directory_NAME/uploads/safetyactionable/photos
mkdir -p $PROJECT_Directory_NAME/uploads/safetyactionable/signatures
mkdir -p $PROJECT_Directory_NAME/uploads/safetyactionable/fingerprints
mkdir -p $PROJECT_Directory_NAME/uploads/incidentsReport/otherWitnessOfIncidentProfilePics
mkdir -p $PROJECT_Directory_NAME/uploads/incidentsReport/witnessesSignatures
mkdir -p $PROJECT_Directory_NAME/uploads/incidentsReport/incidentPhotos
mkdir -p $PROJECT_Directory_NAME/uploads/toolboxtraining/groupPhotos
mkdir -p $PROJECT_Directory_NAME/uploads/toolboxtraining/signatures
mkdir -p $PROJECT_Directory_NAME/uploads/workpermits/signatures
mkdir -p $PROJECT_Directory_NAME/uploads/workpermits/photos
mkdir -p $PROJECT_Directory_NAME/uploads/debitnote/photos
mkdir -p $PROJECT_Directory_NAME/uploads/debitnote/signatures
mkdir -p $PROJECT_Directory_NAME/uploads/debitnote/reports
mkdir -p $PROJECT_Directory_NAME/uploads/safetyreports


##########project Dockerfile##########
cd  /opt/build/project-build/safety-revamp-${PROJECT_Directory_NAME}-build

cat <<'EOF' > Dockerfile

FROM ubuntu:20.04

MAINTAINER anandd@valueaddsofttech.com

RUN apt-get update
RUN apt-get -y install curl gnupg

# Create app directory
WORKDIR /opt/

# Install app dependencies

COPY vsa-revamp-project/ ./

#open port
EXPOSE 3031/tcp

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash
RUN apt-get -y install nodejs
RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get install -y libglib2.0-0
RUN apt-get install -y libatk-bridge2.0-0 libatk1.0-0 libasound2 libcairo2 libcups2 libdbus-1-3 \
libgconf-2-4 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libx11-xcb1 libxcomposite1 \
libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \
fonts-liberation libgbm1
ENV NVM_DIR /usr/local/nvm
RUN mkdir -p /usr/local/nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
ENV NODE_VERSION v18.12.1
RUN /bin/bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm use --delete-prefix $NODE_VERSION"


ENV NODE_PATH $NVM_DIR/versions/node/$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH
CMD npm start

EOF

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

mkdir -p /opt/deploy/project-deploy/safety-revamp-${PROJECT_Directory_NAME}-deploy
cd /opt/deploy/project-deploy/safety-revamp-${PROJECT_Directory_NAME}-deploy

####${PROJECT_NAME} env variables######
cat <<EOF > env.sh
#!/bin/bash
export revampvsa_image=
export VS_PROJ_DB_URL="mongodb://$DB_USER:$DB_PASSWD@192.168.20.101:27017/$DB_NAME"
export VS_ADMIN_INTERNAL_URL="http://192.168.20.101:3030"
export VS_PROJECT_ONE_PORT="$VS_PROJECT_ONE_PORT"
export VS_AUTH_SECRET="LtWpmTC2+tCBPVSirWnzg25rLVc="
export VS_EMAIL_ID=vcgsafetyapp@gmail.com
export VS_EMAILPASSWORD=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
export VS_SENDGRID_API_KEY=apikey
export VS_CLIENT="Team VCG Safety"
export VS_NOTIFICATION_TIME=08:00
export WEEKLY_REPORTS_TIME=11:30
export WEEKLY_REPORTS_DAY=MON
export MONTHLY_REPORTS_TIME=11:30
export MONTHLY_REPORTS_DATE=01
export VS_ADMIN_HOST=http://ck.vastsafetyapp.com
export VS_ADMIN_PORT=3030
export WEEKLY_TIME_FITNESS_CERTIFICATE_MAIL=11:30
export WEEKLY_DAY_FITNESS_CERTIFICATE_MAIL=MON
########Firebase env Variable######
export VS_PROXY_URL=http://192.168.20.101:4050
export VS_FIREBASE_DB_URL=https://vcg-safety-5bf11.firebaseio.com
export VS_FCM1='{
  "type": "service_account",
  "project_id": "vcg-safety-5bf11",
  "private_key_id": "3c534816356a0408fe2ee284eda5e1b79182248c",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDF0UUgDXiNEJi/\n5Mf2VSTAny33uEWyJnqHtGAHK8fc1pES2IHqFagr7gZfh3M+r1wWKlelDGLwZYRs\n/f4RRY9v6iiTDWxAFn6TgN508D/xJPHgFfnd/4oZDLmTfVihKJMVJLKksdLU5u61\nhtMtq9/2KO8uib89vwvJCnUIAHPPvqs+H3UmtNNr1P5eufiYGVTwvYkdNkipnszx\nwjFhLkVF2U+ksr69LPzgLkoyOkrY0d1J9VWS8DzkyyqeC283tUL9Bo9vfe5GF/qo\ndjwJNcVGcXS2vx2KhZjFpccqhQuu1SAxEZaUE727ppUEwmNmKFCF7clWyYmJ2FnQ\nk1UV8rlrAgMBAAECggEAFMpx4XSI/wqHg2OgQJuiSTxxsF+Fs7unlSu4DAjl8Kf8\nh2aKAPhVvIg/0zqBOk1j+FBq9cXfgDSrPmlTkq0k7jZGHW6DuhijJQ2eU9wMXGPt\nqAenQ1XgRdG4j2/VKNsC2m4I+JZX+lhrLlkFSP+Pgme6+8EugGbb7j1TH4wsn+DS\n/Xm4e7b6WH7sIF3rcuYp0FpSjn2+J2a645vmNzBVU7QUWTeOO7YZHoKbjRGBgogO\nzSHnDfRGSzuZLNPjnXSSBkvz6v4tPlGOCaLhEFQ/mnCqFJRXgVIBS0fhncV+5wGv\nrPgIYSNQpgxUjuFtu8fXa+zH15MKBefqKjegRRuTwQKBgQDmdvPdEPXoJMnC6Z8+\n99MrIj/+mxijJeMo38iLBb5CcbjYebn6nhOJ54krxvRLCFCSWm/tzpjjEKaFPmgU\nVxM9+HzwxyivImA7rKlO2M449dywDzZUnMxgf1oV9gPhZhVLal/JW33H6CVDCl7M\npOPZKHxD2Eb+rarwdNtmLzHo/wKBgQDbvEqXleoakoSq+2vBB2MgWORPAyU0Vqei\nfyPNfWMO3nsmGPym3KJWjcP24uiw31AvF1ZFlFj6G26EWrFQH6jgoxbEwTsSq6RB\n/KiNVHssn6kdqHwlL/jAQTKI2wqnluzG2gggIdn7bL3g37RKcfiHR+EtUrIOPoVr\nECFkd7TjlQKBgQDfknwGdEKqHq4gSPU0Z8RSbtp4C0u+Ua3p5BYvT7X/zUTNtGDI\nEHvR52x5rHsnIvzOza8Rmr9UX727OwxK1yISlzHVfs8n/wguO9TPaaG9Pj4GCevh\n726RGlpxPYUMLzTvQVWFCB2gRcOIItJOYpOrAgxy4KgWvrE6rZJ9scEQTwKBgAZK\nOYhlTjI8h3etgsQfxgKjCMYKPQJmiJ3qLcgwEqnWTIgmpvTP1AXOQRHMJQULH2x5\nqoqLWJCwQFWhkvnMLjVf9cLkFSDPsQACj4CcLnp0h47Fx+f4m5JFS4EHZCKv+08l\n5p2k2myMDFNnk+2dnZOhxxxZBafKul76MzqBAriRAoGBAIhGPABwSBrzhwTEuzQV\nbzncgWEh1Z7kpsb2hopzoHKly9Wghy4uT6TLQwbjLw4sMijK2DCtQqGep+7EVJPP\nMJIE6enVxZS86z0qD+ZXB6yuMZUxOcJxiyAcV/fY5p5ia9ED64S/c9ESLiqbP59n\nx8Z82rJF8y67fd9tQMJtL6QK\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-sc8yq@vcg-safety-5bf11.iam.gserviceaccount.com"
}'
export VS_FCM2='{
  "client_id": "106504935792197283508",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-sc8yq@vcg-safety-5bf11.iam.gserviceaccount.com"
}'
EOF

sed -i "s/^export revampvsa_image=.*/export revampvsa_image=\"project:$GIT_TAG\"/" /opt/deploy/project-deploy/safety-revamp-${PROJECT_Directory_NAME}-deploy/env.sh

chmod +x env.sh
source /opt/deploy/project-deploy/safety-revamp-${PROJECT_Directory_NAME}-deploy/env.sh

########$PROJECT_NAME docker-compose file############

cat <<'EOF' > docker-compose.yml
version: '3.8'
services:
  safety-revamp:
    image: ${revampvsa_image}
    ports:
      - ${VS_PROJECT_ONE_PORT}:${VS_PROJECT_ONE_PORT}
    deploy:
      replicas: 1
    environment:
      - VS_PROJ_DB_URL=${VS_PROJ_DB_URL}
      - VS_PROJECT_ONE_PORT=${VS_PROJECT_ONE_PORT}
      - VS_ADMIN_INTERNAL_URL=${VS_ADMIN_INTERNAL_URL}
      - VS_AUTH_SECRET=${VS_AUTH_SECRET}
      - VS_PROXY_URL=${VS_PROXY_URL}
      - VS_FIREBASE_DB_URL=${VS_FIREBASE_DB_URL}
      - VS_FCM1=${VS_FCM1}
      - VS_FCM2=${VS_FCM2}
      - VS_EMAIL_ID=${VS_EMAIL_ID}
      - VS_EMAILPASSWORD=${VS_EMAILPASSWORD}
      - VS_SENDGRID_API_KEY=${VS_SENDGRID_API_KEY}
      - VS_CLIENT=${VS_CLIENT}
      - VS_NOTIFICATION_TIME=${VS_NOTIFICATION_TIME}
      - WEEKLY_REPORTS_TIME=${WEEKLY_REPORTS_TIME}
      - WEEKLY_REPORTS_DAY=${WEEKLY_REPORTS_DAY}
      - MONTHLY_REPORTS_TIME=${MONTHLY_REPORTS_TIME}
      - MONTHLY_REPORTS_DATE=${MONTHLY_REPORTS_DATE}
      - WEEKLY_TIME_FITNESS_CERTIFICATE_MAIL=${WEEKLY_TIME_FITNESS_CERTIFICATE_MAIL}
      - WEEKLY_DAY_FITNESS_CERTIFICATE_MAIL=${WEEKLY_DAY_FITNESS_CERTIFICATE_MAIL}
      - VS_ADMIN_HOST=${VS_ADMIN_HOST}
      - VS_ADMIN_PORT=${VS_ADMIN_PORT}
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /mnt/${PROJECT_Directory_NAME}/uploads:/opt/uploads
EOF

docker stack rm ${PROJECT_Directory_NAME}
sleep 15
docker stack deploy -c docker-compose.yml ${PROJECT_Directory_NAME}


