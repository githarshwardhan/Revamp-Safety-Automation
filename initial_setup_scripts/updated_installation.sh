#########docker Installation##########

#!/bin/bash
echo "Installing Docker"
if [ ! -f /usr/bin/docker ]
then
sudo apt update -y
sudo apt-get install curl -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce -y
sudo apt install docker-ce -y
sudo systemctl start docker
sudo systemctl daemon-reload
sudo systemctl enable docker
docker --version
else

        echo "<<<Docker is ALready Present>>>"
fi

#########docker-swarm##########

docker swarm init 

########UFW installation##############
echo "Installing UFW and configuring firewall rules"

# Install UFW
sudo apt-get update
sudo apt-get install ufw -y

# Enable UFW
sudo ufw enable

# Allow incoming traffic on specific ports
sudo ufw allow 443     # HTTPS
sudo ufw allow 22      # SSH
sudo ufw allow 122     # Custom Port 122 (adjust as needed)
sudo ufw allow 27017   # MongoDB

# Display UFW status
sudo ufw status verbose

echo "UFW installation and configuration completed."
#########Mongodb Installation#########

#!/bin/bash
echo "Installing MONGODB v6.0.10"
if [ ! -f /usr/bin/mongod ]
then
sudo  apt install gnupg -y
sudo apt-get install wget -y
sudo apt-get install git -y
sudo apt-get install curl -y


# Import MongoDB GPG key
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg --dearmor

# Add MongoDB repository to sources.list.d
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Update package list
sudo apt-get update -y

# Install MongoDB packages
sudo apt-get install -y mongodb-org=6.0.10 mongodb-org-database=6.0.10 mongodb-org-server=6.0.10 mongodb-org-mongos=6.0.10 mongodb-org-tools=6.0.10


# Set package holds
echo "mongodb-org hold" | sudo dpkg --set-selections
echo "mongodb-org-database hold" | sudo dpkg --set-selections
echo "mongodb-org-server hold" | sudo dpkg --set-selections
echo "mongodb-mongosh hold" | sudo dpkg --set-selections
echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
echo "mongodb-org-tools hold" | sudo dpkg --set-selections

sudo systemctl start mongod
sudo systemctl daemon-reload
sudo systemctl enable mongod
sudo systemctl stop mongod
sleep 3
sudo systemctl restart mongod
sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf
sudo systemctl enable mongod
sudo systemctl restart mongod
cat /etc/mongod.conf
sleep 10
mongosh --version
mongod --version
else
        echo "<<<MONGODB v.6.0.10 is ALready Present>>>"
fi

####Enable the Mongodb authentication#######

mongosh --host localhost --port 27017 <<EOF
use admin
db.createUser({ user: "adminuser", pwd: " saFeTyaPp2o24 ", roles: ["root"]})

EOF

#Enable authentication in /etc/mongod.conf
CONFIG_FILE="/etc/mongod.conf"
CONTENT_TO_ADD="security:
  authorization: enabled"

# Check if the file exists, and if it does, add the content
if [ -e "$CONFIG_FILE" ]; then
  # Add the content to the file
  echo "$CONTENT_TO_ADD" | sudo tee -a "$CONFIG_FILE" > /dev/null
  echo "Content added to $CONFIG_FILE"
else
  echo "File not found: $CONFIG_FILE"
fi

systemctl restart mongod
sleep 3

########Mongodb db creation##################
mongosh --host localhost --port 27017 -u adminuser -p  saFeTyaPp2o24  --authenticationDatabase admin <<EOF
use clientadmindb
db.createUser({user: "safetyappadmin",pwd: ' saFeTyaPp2o24 ', roles: [ { role: "dbOwner", db: "clientadmindb" } ]})
     db.users.insert({
   "firstName":"Admin",
   "lastName":"User",
   "username":"admin",
   "email":"support@constructionsafetyapp.com",
   "phoneNumber":"9988776655",
   "isAdmin":true,
   "isActive":true,
   "password":"\$2b\$10\$N/WLUzfhQbVe11hoU/4mNO1YyqSXXnKUEGRDAHiNVGQll1VS5JXXC",
   "idProofType":"Pan Card",
   "idProofNumber":"FS23BD75676",
   "type":"Internal"
});

EOF
#################


#########Node Installation##########

#!/bin/bash

# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# Source nvm in the current script
source ~/.nvm/nvm.sh

# Install Node.js version 18.12.1
nvm install v18.12.1

# Use Node.js version 18.12.1
nvm use v18.12.1

# Verify Node.js and npm versions
node -v
npm -v


##########Nginx Installation#########

apt install nginx -y
sleep 5

################ AWS Installation #####################

sudo apt install awscli -y
aws configure

######################################################
