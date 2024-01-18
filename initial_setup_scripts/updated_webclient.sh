#!/bin/bash
## add  /root/index/index.html before executing 
read -p "Enter Git Tag:" GITTAG
export GITTAG
rm -rf  /root/index/index.html
cd  /opt/static-deployment/
cp -r /opt/static_deployment/vsa-revamp-webclient/public/index.html /root/index/
rm -r vsa-revamp-webclient
git clone -b $GITTAG  https://token:AhaQ2ovu_4AUe8d1MQPm@gitlab.valueaddsofttech.com/safetyrevamp/vsa-revamp-webclient.git 
version=$(cat /opt/static_deployment/cksafetyrevamp/vsa-revamp-webclient/version.txt); sed -Ei "s/(Version: )[0-9]+\.[0-9]+\.[0-9]+/\1$version/" /opt/static_deployment/cksafetyrevamp/vsa-revamp-webclient/src/Login/components/LoginForm.tsx; echo "Version number in LoginForm.tsx updated to: $version"

cd /opt/static_deployment/vsa-revamp-webclient/public
                rm -rf fevicon.ico
                rm -rf index.html
                cd /opt/static_deployment/vsa-revamp-webclient/src/
                rm -rf customization
                cd /tmp/
                rm -rf vsa-customization
                git clone  https://token:AhaQ2ovu_4AUe8d1MQPm@gitlab.valueaddsofttech.com/safetyrevamp/vsa-customization.git
                cd /tmp/vsa-customization
                mv 'CK Safety' cksafety
 cp -r /tmp/vsa-customization/cksafety/fevicon.ico  /opt/static_deployment/vsa-revamp-webclient/public/
 cp -r /root/index/index.html /opt/static_deployment/vsa-revamp-webclient/public/
 cp -r /tmp/vsa-customization/cksafety/customization /opt/static_deployment/vsa-revamp-webclient/src/
 cd /opt/static_deployment/vsa-revamp-webclient
 . ~/.nvm/nvm.sh
 nvm use v18.12.1
npm install
echo "###########################################################################################"
sleep 10
echo "Create the Static build file"
        cd /opt/static_deployment/vsa-revamp-webclient
        npm run build
        ls -l /opt/static_deployment/vsa-revamp-webclient/build
sleep 5
# Remove the old build file from /var/www/html/safety_revamp_web_qa/
        rm -rf /var/www/html/revamp/*
sleep 5
echo "###########################################################################################"

echo "Update the html file in /var/www/html/revamp/"
        cp -r /opt/static_deployment/vsa-revamp-webclient/build/* /var/www/html/revamp/
sleep 5
echo "Verify on browser"
