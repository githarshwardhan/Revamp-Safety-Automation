#!/bin/bash

read -p "Enter Git Tag:" GITTAG
export GITTAG
##############Create directories########################
mkdir -p /opt/build/admin-build/safety-revamp-admin-build
mkdir -p /opt/deploy/admin-deploy/safety-revamp-admin-deploy
mkdir -p /opt/static-deployment
#################

cd /opt/build/admin-build/safety-revamp-admin-build/

git clone https://token:AhaQ2ovu_4AUe8d1MQPm@gitlab.valueaddsofttech.com/safetyrevamp/vsa-revamp-admin.git -b $GITTAG

mongoimport --db clientadmindb --host localhost --port 27017 --username safetyappadmin --password saFeTyaPp2o24 --collection idprooftypes --type json --file "vsa-revamp-admin/src/scripts/day0/idprooftypes.json"

mongoimport --db clientadmindb --host localhost --port 27017 --username safetyappadmin --password saFeTyaPp2o24 --collection entitlements --type json --file "vsa-revamp-admin/src/scripts/day0/entitlements.json"

mongoimport --db clientadmindb --host localhost --port 27017 --username safetyappadmin --password saFeTyaPp2o24 --collection roles --type json --file "vsa-revamp-admin/src/scripts/day0/roles.json"

mongoimport --db clientadmindb --host localhost --port 27017 --username safetyappadmin --password saFeTyaPp2o24 --collection categories --type json --file "vsa-revamp-admin/src/scripts/day0/categories.json"

mongoimport --db clientadmindb --host localhost --port 27017 --username safetyappadmin --password saFeTyaPp2o24 --collection statuses --type json --file "vsa-revamp-admin/src/scripts/day0/statuses.json"

mongoimport --db clientadmindb --host localhost --port 27017 --username safetyappadmin --password saFeTyaPp2o24 --collection rootcauses --type json --file "vsa-revamp-admin/src/scripts/day0/rootcauses.json"

mongoimport --db clientadmindb --host localhost --port 27017 --username safetyappadmin --password saFeTyaPp2o24 --collection emailconfigurations --type json --file "vsa-revamp-admin/src/scripts/day0/emailconfigurations.json"

mongoimport --db clientadmindb --host localhost --port 27017 --username safetyappadmin --password saFeTyaPp2o24 --collection relationships --type json --file "vsa-revamp-admin/src/scripts/day0/relationships.json"

mongoimport --db clientadmindb --host localhost --port 27017 --username safetyappadmin --password saFeTyaPp2o24 --collection notifications --type json --file "vsa-revamp-admin/src/scripts/day0/notifications.json"

mongoimport --db clientadmindb --host localhost --port 27017 --username safetyappadmin --password saFeTyaPp2o24 --collection serviceareas --type json --file "vsa-revamp-admin/src/scripts/day0/serviceareas.json"

mongoimport --db clientadmindb --host localhost --port 27017 --username safetyappadmin --password saFeTyaPp2o24 --collection labourformfields --type json --file "vsa-revamp-admin/src/scripts/day0/labourformfields.json"

mongoimport --db clientadmindb --host localhost --port 27017 --username safetyappadmin --password saFeTyaPp2o24 --collection safetyactionabletypes --type json --file "vsa-revamp-admin/src/scripts/day0/safetyactionabletypes.json"

mongoimport --db clientadmindb --host localhost --port 27017 --username safetyappadmin --password saFeTyaPp2o24 --collection safetyactionablecategories --type json --file "vsa-revamp-admin/src/scripts/day0/safetyactionablecategories.json"

#####uploads folder for admin####
cd /mnt
mkdir -p admin_uploads/users/profile
mkdir -p admin_uploads/inductiontraining/inductioncategorydocs
mkdir -p admin_uploads/inductiontraining/idproofphotos
mkdir -p admin_uploads/inductiontraining/photos
mkdir -p admin_uploads/toolboxtraining/documents
mkdir -p admin_uploads/contractorfirm/images
mkdir -p admin_uploads/contractorfirm/workorderphotos
mkdir -p admin_uploads/workpermit/documents

####Admin Dockerfile######
cd /opt/build/admin-build/safety-revamp-admin-build

cat <<EOF > Dockerfile
FROM ubuntu:20.04
RUN apt-get update
RUN apt-get -y install curl gnupg

# Create app directory
WORKDIR /opt/

# Install app dependencies

COPY vsa-revamp-admin/ ./

#open port
EXPOSE 3030/tcp

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash
RUN apt-get -y install nodejs
RUN apt-get update
RUN apt-get install -y apt-utils
ENV NVM_DIR /usr/local/nvm
RUN mkdir -p /usr/local/nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
ENV NODE_VERSION v18.12.1
RUN /bin/bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm use --delete-prefix $NODE_VERSION"
ENV NODE_PATH $NVM_DIR/versions/node/$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH
CMD npm start
EOF

######create docker image with Git tag############
cd /opt/build/admin-build/safety-revamp-admin-build/
cat <<EOF > build_admin_image.sh
#############################################################################################
# FUNCTION TRAP
#############################################################################################
function error_trap()
{
        if [ "$?" -ne "0" ]
        then
                echo "Error !!! \"$0\" Script Failed at \"$BASH_COMMAND\" command "
        else
                echo "Success !!! \"$0\" Script executed successfully in \"$SECONDS\" seconds"
        fi

}

        trap error_trap EXIT
        set -e
#############################################################################################
GIT_TAG=$(cat version.txt | tr -d '\n')
echo $GIT_TAG
cd /opt/build/admin-build/safety-revamp-admin-build/
rm -rf /opt/build/admin-build/safety-revamp-admin-build/vsa-revamp-admin
git clone https://token:AhaQ2ovu_4AUe8d1MQPm@gitlab.valueaddsofttech.com/safetyrevamp/vsa-revamp-admin.git -b $GITTAG
cd /opt/build/admin-build/safety-revamp-admin-build/vsa-revamp-admin
latest_tag=`cat version.txt`
echo "#################### $latest_tag #########################"
mkdir -p /opt/build/cksafetyrevamp/admin/vsa-revamp-admin/uploads/
####################COPY BACKEND CUSTOMIZATION###################
rm -rf /opt/build/admin-build/safety-revamp-admin-build/vsa-revamp-admin/backend_customization
cd /tmp/
rm -rf vsa-customization
git clone  https://token:AhaQ2ovu_4AUe8d1MQPm@gitlab.valueaddsofttech.com/safetyrevamp/vsa-customization.git
cd /tmp/vsa-customization
mv 'CK Safety' cksafety
cp -r /tmp/vsa-customization/cksafety/backend_customization /opt/build/cksafetyrevamp/admin/vsa-revamp-admin/
cd /opt/build/cksafetyrevamp/admin/vsa-revamp-admin/
env
. ~/.nvm/nvm.sh
nvm use v18.12.1
npm install
##############################################################################################
#Login the AWS ECR for pushing the image
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 882647124176.dkr.ecr.ap-south-1.amazonaws.com
##############################################################################################
#Build the Docker image
        echo -e "========== Building Docker Image . . . . . !"
        cd /opt/build/admin-build/safety-revamp-admin-build
        docker build -t $GIT_TAG:$latest_tag .
        docker tag $GIT_TAG:$latest_tag 882647124176.dkr.ecr.ap-south-1.amazonaws.com/revampsafety/pre_dev:$GIT_TAG-$latest_tag
        docker push 882647124176.dkr.ecr.ap-south-1.amazonaws.com/revampsafety/pre_dev:$GIT_TAG-$latest_tag
        docker rmi $GIT_TAG:$latest_tag
##############################################################################################
echo "!!!!!!!DONE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

cd ..

# Check if the Docker image exists
if docker image inspect admin:$GIT_TAG &> /dev/null; then
    echo "Docker image admin:$GIT_TAG exists."
else
    echo "Docker image admin:$GIT_TAG not exist. Building..."
    docker build -t admin:$GIT_TAG .
fi
EOF

cd /opt/deploy/admin-deploy/safety-revamp-admin-deploy
####Admin env variables######
cat <<'EOF' > env.sh

#!/bin/bash
export revampvsa_image=
export VS_ADMIN_DB_URL="mongodb://safetyappadmin:saFeTyaPp2o24@IP:27017/clientadmindb"
export VS_ADMIN_PORT=3030
export VS_AUTH_SECRET=""
export VS_CLIENT_EMAIL_ACC=false
export VS_EMAIL_ID=@gmail.com
export VS_EMAIL_SERVICE_HOST=smtp.rediffmailpro.com
export VS_EMAIL_SERVICE_PORT=587
export VS_SECURE_CONNECTION=false
export VS_SENDGRID_API_KEY=apikey
export VS_EMAILPASSWORD=""
export VS_CLIENT_URL="https://something.subdomain.com"
export VS_CLIENT="VAST"
export VS_CLIENT_HOST="https://something.subdomain.com"
export VS_CLIENT_PORT=3000
export VS_APP_NAME="add here"
export VS_IOS_LINK="comming soon"
export VS_ANDROID_LINK="comming soon"
export VS_LOG_LEVEL="info"
export VS_REFRESH_AUTH_SECRET=b713e16b5f9df87294f43baeba0e559905db8621f3116fb51b58b43cfea5
export VS_REFRESH_TOKEN_EXPIRES_IN=180d
export VS_REFRESH_TOKEN_TTL=15552000
export VS_ACCESS_TOKEN_EXPIRES_IN=30d
export DOCUMENT_EXPIRY_SCHEDULER_TIME=11:00
export VS_TBT_WISE_LABOUR_REPORT_EMAIL_RECIPIENTS_LIST=support@constructionsafetyapp.com
export VS_TBT_WISE_LABOUR_REPORT_SCHEDULER_TIME=12:00
########Firebase env Variable######
export VS_PROXY_URL=https://something.subdomain.com
export VS_FIREBASE_DB_URL=https://project_id.firebaseio.com
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

# Update the environment variables to deploy latest docker image
sed -i "s|882647124176.dkr.ecr.ap-south-1.amazonaws.com/.*|882647124176.dkr.ecr.ap-south-1.amazonaws.com/revampsafety/pre_dev:$GIT_MASTER_BRANCH-$latest_tag|g" /opt/deploy/cksafetyrevamp/admin_deployment/env.sh
chmod +x env.sh
source env.sh

###########docker-compose file#####
cat <<'EOF' > docker-compose.yml

version: '3.8'
services:
  safety-revamp1:
    image: ${revampvsa_image}
    ports:
      - ${VS_CLIENT_PORT}:3000
      - ${VS_ADMIN_PORT}:3030
    deploy:
      replicas: 1
    environment:
      - VS_ADMIN_DB_URL=${VS_ADMIN_DB_URL}
      - VS_ADMIN_PORT=${VS_ADMIN_PORT}
      - VS_AUTH_SECRET=${VS_AUTH_SECRET}
      - VS_CLIENT_EMAIL_ACC=${VS_CLIENT_EMAIL_ACC}
      - VS_EMAIL_ID=${VS_EMAIL_ID}
      - VS_EMAIL_SERVICE_HOST=${VS_EMAIL_SERVICE_HOST}
      - VS_EMAIL_SERVICE_PORT=${VS_EMAIL_SERVICE_PORT}
      - VS_SECURE_CONNECTION=${VS_SECURE_CONNECTION}
      - VS_SENDGRID_API_KEY=${VS_SENDGRID_API_KEY}
      - VS_EMAILPASSWORD=${VS_EMAILPASSWORD}
      - VS_CLIENT_URL=${VS_CLIENT_URL}
      - VS_CLIENT=${VS_CLIENT}
      - VS_CLIENT_HOST=${VS_CLIENT_HOST}
      - VS_CLIENT_PORT=${VS_CLIENT_PORT}
      - VS_APP_NAME=${VS_APP_NAME}
      - VS_IOS_LINK=${VS_IOS_LINK}
      - VS_ANDROID_LINK=${VS_ANDROID_LINK}
      - VS_PROXY_URL=${VS_PROXY_URL}
      - VS_FIREBASE_DB_URL=${VS_FIREBASE_DB_URL}
      - VS_LOG_LEVEL=${VS_LOG_LEVEL}
      - VS_FCM1=${VS_FCM1}
      - VS_FCM2=${VS_FCM2}
      - VS_REFRESH_AUTH_SECRET=${VS_REFRESH_AUTH_SECRET}
      - VS_REFRESH_TOKEN_EXPIRES_IN=${VS_REFRESH_TOKEN_EXPIRES_IN}
      - VS_REFRESH_TOKEN_TTL=${VS_REFRESH_TOKEN_TTL}
      - VS_ACCESS_TOKEN_EXPIRES_IN=${VS_ACCESS_TOKEN_EXPIRES_IN}
      - DOCUMENT_EXPIRY_SCHEDULER_TIME=${DOCUMENT_EXPIRY_SCHEDULER_TIME}
      - VS_TBT_WISE_LABOUR_REPORT_EMAIL_RECIPIENTS_LIST=${VS_TBT_WISE_LABOUR_REPORT_EMAIL_RECIPIENTS_LIST}
      - VS_TBT_WISE_LABOUR_REPORT_SCHEDULER_TIME=${VS_TBT_WISE_LABOUR_REPORT_SCHEDULER_TIME}
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /mnt/admin_uploads:/opt/uploads
EOF
###########admin-deployment file#####
cat <<'EOF' > admin-deployment.sh 
#!/bin/bash
#########################################################################
folderpath=$1
#########################################################################
function error_trap()
{
        if [ "$?" -ne "0" ]
        then
                echo "Error !!! \"$0\" Script Failed at \"$BASH_COMMAND\" command "
        else
                echo "Success !!! \"$0\" Script executed successfully in \"$SECONDS\" seconds"
        fi

}

trap error_trap EXIT
set -e

cd /opt/deploy/admin-deploy/safety-revamp-admin-deploy
docker stack rm safetyrevamp_admin
sleep 30
source cd /opt/deploy/admin-deploy/safety-revamp-admin-deploy/env.sh
docker stack deploy -c docker-compose.yml safetyrevamp_admin

####################################################################################

