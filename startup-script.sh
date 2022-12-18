#...................................................................................................#
#                                                                                                   #
#  @License Starts                                                                                  #
#                                                                                                   #
#  Copyright © 2015 - present. MongoExpUser.  All Rights Reserved.                                  #
#                                                                                                   #
#  License: MIT - https://github.com/MongoExpUser/UNEMO-Stack-on-AWS-Lightsail/blob/main/README.md  #
#                                                                                                   #
#  @License Ends                                                                                    #
#                                                                                                   #
#...................................................................................................#
#  startup-script.sh (lauch/start-up script) - performs the following actions:                      #
#  1) Installs additional Ubuntu packages                                                           #
#  2) Installs and configures Node.js v16.x and Express v5.0.0-alpha.8 web server framework         #
#     Installs other node.js packages and set firewall rules for web server                         #
#  3) Installs and configures mongodb server and set firewall rules for mongodb server              #
#...................................................................................................#


#!/bin/bash

# define all common variable(s)
base_dir="base"
server_dir="server"
client_dir="client"
enable_web_server=true
enable_mongodb_server=true

create_dir_and_install_missing_packages () {
  # create relevant directories
  cd /home/
  sudo mkdir $base_dir
  cd $base_dir
  sudo mkdir $server_dir
  sudo mkdir $client_dir
      
  # update system
  sudo apt-get update
  echo -e "Y"
  sudo apt-get upgrade
  echo -e "Y"
  echo -e "Y"
  echo -e "Y"
  sudo apt-get dist-upgrade
  echo -e "Y"
  echo -e "Y"
  echo -e "Y"
      
  #install additional missing packages
  sudo apt-get install sshpass
  sudo apt install cmdtest
  echo -e "Y"
  sudo apt-get install spamassassin
  echo -e "Y"
  sudo apt-get install snap
  sudo apt-get install nmap
  echo -e "Y"
  sudo apt-get install net-tools
  sudo apt-get install aptitude
  echo -e "Y"
  sudo apt-get install build-essential
  echo -e "Y"
  sudo apt-get install gcc
  echo -e "Y"
  echo -e "Y"
  sudo apt-get install python3-pip
  echo -e "Y"
  echo -e "Y"
  sudo python3 -m pip install boto3
  echo -e "Y"
  
  
  #install certbot for letsencrypt' ssl certificate renewal
  sudo apt install certbot python3-certbot-apache
  echo -e "Y"
  echo -e "Y"
  
  # clean
  sudo apt autoclean
  echo -e "Y"
  echo -e "Y"
  sudo apt autoremove
  echo -e "Y"
  echo -e "Y"
}

install_and_configure_nodejs_web_server () {
  cd /home/
  cd $base_dir
  
  if [ $enable_web_server = true ]
  then
    # install node.js
    curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    echo -e "\n"
    sudo apt-get install -y nodejs
    echo -e "\n"
        
    # create node.js' package.json file
    sudo echo ' {
      "name": "Nodejs-Expressjs",
      "version": "1.0",
      "description": "A web server, based on the Node.js-Express.js (NE) stack",
      "license": "MIT",
      "main": "./app.js",
      "email": "info@domain.com",
      "author": "Copyright © 2015 - present. MongoExpUser.  All Rights Reserved.",
      "dependencies"    :
      {
        "express"       : "*"
      },
      "devDependencies": {},
      "keywords": [
        "Node.js",
        "Express.js",
        "MongoDB\""
      ]
    }' > package.json
        
    # install express.js (the web server framework) and other node.js packages
    sudo npm i express@5.0.0-alpha.8
    sudo npm i -g npm
    sudo npm i aws-sdk
    sudo npm i bcryptjs
    sudo npm i bcrypt-nodejs
    sudo npm i bindings
    sudo npm i bluebird
    sudo npm i body-parser
    sudo npm i command-exists
    sudo npm i compression
    sudo npm i connect-flash
    sudo npm i cookie-parser
    sudo npm i express-session
    sudo npm i formidable
    sudo npm i html-minifier
    sudo npm i level
    sudo npm i memored
    sudo npm i mime
    sudo npm i mkdirp
    sudo npm i pg
    sudo npm i ocsp
    sudo npm i mongodb
    sudo npm i s3-proxy
    sudo npm i python-shell
    sudo npm i serve-favicon
    sudo npm i serve-index
    sudo npm i uglify-js2
    sudo npm i uglify-js@2.2.0
    sudo npm i uglifycss
    sudo npm i uuid
    sudo npm i vhost
    
    #enable firewall
    sudo ufw enable
    echo -e "Y"
    
    # set firewall rules for ssh (port 22) and web-server (80 & 443)
    echo -e "Y"
    sudo ufw allow 22
    sudo ufw allow 80
    sudo ufw allow 443
              
    # clean
    sudo apt autoclean
    sudo apt autoremove
  fi
}



install_and_configure_mongodb_server () {
  if [ $enable_mongodb_server == true ]
  then
    # 1. install mongodb server, client and other tools - version 6.0
    # version 6.0 supports Ubuntu 20.04 LTS but not 22.04 LTS yet as at Dec 16 2022
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    sudo apt-get -y update
    sudo apt-get install -y mongodb-org
    echo -e "Y"
    echo -e "Y"
    
    # set firewall rule for mongodb-server
    echo -e "Y"
    sudo ufw allow 27017
    
    # clean
    sudo apt autoclean
    sudo apt autoremove
    
    
# create relevant mongodb files: logging, configuration, tls/ssl and keyFile (security) files
# note  - files include:
# 1) mongod.log           - COMPULSORY            - /var/log/mongodb/mongod.log  - logging
# 2) mongod.conf          - COMPULSORY            - /etc/mongod.conf             - configuration
# 3) certificateKeyFile   - OPTIONAL for tls/ssl  - /etc/ssl/mongodb.pem         - tls/ssl
# 4) CAFile               - OPTIONAL for tls/ssl  - /etc/ssl/ca.pem              - tls/ssl
# 5) clusterFile          - OPTIONAL for tls/ssl  - /etc/ssl/mongodb.pem         - tls/ssl
# 6) keyFile              - OPTIONAL for replica  - /etc/ssl/keyFile.key         - security


# 1. create mongod.log file and set its permission
sudo echo '# mongod.log file' > /var/log/mongodb/mongod.log
sudo chmod -R 777 /var/log/mongodb/mongod.log
    

# 2. re-create or edit mongod.conf file with initial: storage, log, net, process, monitoring, security and other desired settings
sudo echo '# mongod.conf file

# for documentation of all options, see:
# http://docs.mongodb.org/manual/reference/configuration-options/
      
# where to store data
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true
      
# where to write logging data
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log
      
# network interfaces
net:
  port: 27017
  #bindIp: 127.0.0.1                              # bind to localhost: this is the default option in MongoDB Version V3.6.0 and above
  bindIpAll: true                                 # allow all IPs in MongoDB Version V3.6.0 and above: but remember to filter out at firewall level
  #bindIp: localhost,<endpoint(s)|ip address(es)> # allow only specified endpoint(s) or ip address(es)
  tls:
    mode: disabled                              # disabled or requireTLS
    #certificateKeyFile: /etc/ssl/mongodb.pem   # required for TLS
    #CAFile:             /etc/ssl/ca.pem        # required for TLS
    #clusterFile:        /etc/ssl/mongodb.pem   # required for REPLICA: if not specified would use "certificateKeyFile"
           
# how the process runs
processManagement:
  timeZoneInfo: /usr/share/zoneinfo
        
# security: enable after installation and creation of main admin user
security:
  authorization: disabled                # disabled or  enabled
  #keyFile: /etc/ssl/keyFile.key         # required for REPLICA
  #clusterAuthMode: keyFile              # required for REPLICA: accept only keyFile
        
# replication: if needed or required, enable after installation and creation of main admin user
#replication:                            # required for REPLICA
  #replSetName: mongodb-prod-repl        # required for REPLICA - for configuration RepSet
  
# for other desired configuration settings, see: http://docs.mongodb.org/manual/reference/configuration-options/
  
' > /etc/mongod.conf


# 3. create tls/ssl certificateKeyFile  file: /etc/ssl/mongodb.pem
sudo echo '# add certificateKeyFile content here
' > /etc/ssl/mongodb.pem


# 4. create  tls/ssl CAFile  file: /etc/ssl/ca.pem
sudo echo '# add CAFile content here
' > /etc/ssl/ca.pem


# 5. create  tls/ssl clusterFile  file: /etc/ssl/mongodb.pem
sudo echo '# add clusterFile content here
' > /etc/ssl/mongodb.pem


# 6. create  security file: /etc/ssl/keyFile.key - security
sudo echo '# add keyFile content here
' > /etc/ssl/keyFile.key


    # set permission on keyFile.key file: do this on each replicas
    sudo chmod 400 /etc/ssl/keyFile.key
    
    # change ownership to mongodb on keyFile.key file: do this on all replicas
    sudo chown mongodb:mongodb /etc/ssl/keyFile.key
    
    # by default, mongdb is not started after installtion
    # to START MongoDB automatically as part of this deployment, leave the next line uncommented:
    sudo mongod --quiet --config /etc/mongod.conf
        
    # To STOP MongoDB:
    # sudo mongod --quiet --dbpath /var/lib/mongodb --shutdown
    
    # FOR PRODUCTION deployment, ensures:
    # a) username(s) and password(s), with relevant privileges, are created for login
    # b) authorization is enabled, under security settings, in the configuration file (mongod.conf)
    
  fi
}


main () {
  # execute all functions sequentially
  create_dir_and_install_missing_packages
  install_and_configure_nodejs_web_server
  install_and_configure_mongodb_server
}

# invoke main
main
