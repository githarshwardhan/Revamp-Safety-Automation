#!/bin/bash

read -p "Enter Git Tag:" GITTAG
export GITTAG

cd  /opt/static-deployment/

rm -r vsa-revamp-webclient

git clone -b $GITTAG  https://aniketb:rXsbnGcJGpfbcqyDYxvT@gitlab.valueaddsofttech.com/safetyrevamp/vsa-revamp-webclient.git


cd vsa-revamp-webclient

npm i

sleep 4

npm run build
cd /var/www/html
rm -r build
cd /opt/static-deployment/vsa-revamp-webclient
cp -r build /var/www/html

