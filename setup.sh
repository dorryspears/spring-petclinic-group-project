#!/bin/bash

ROOT_PWD=$PWD
# pre-installation
# Step 1: Curl zip 
mkdir -p backup
cd backup
pip3 install gdown
gdown 1SCn5TG1KIn2Za0plufOoh4FnknzUDdp6
unzip final_devops.zip

# move all tar files from final_devops folder into current backup
mv final_devops/* .

# Step 2: Create volumes
docker volume create jenkins-data
docker volume create jenkins_home
docker volume create jenkins-docker-certs
docker volume create grafana-storage
docker volume create prometheus-data

cd "$ROOT_PWD"

# Step 3: Untar + Upload / Restore volume
docker run --rm -v jenkins_home:/volume -v $PWD/backup:/backup alpine sh -c "rm -rf /volume/* && tar -xvf /backup/jenkins_home.tar -C /volume"
docker run --rm -v jenkins-data:/volume -v $PWD/backup:/backup alpine sh -c "rm -rf /volume/* && tar -xvf /backup/jenkins-data.tar -C /volume"
docker run --rm -v jenkins-docker-certs:/volume -v $PWD/backup:/backup alpine sh -c "rm -rf /volume/* && tar -xvf /backup/jenkins-docker-certs.tar -C /volume"
docker run --rm -v grafana-storage:/volume -v $PWD/backup:/backup alpine sh -c "rm -rf /volume/* && tar -xvf /backup/grafana-storage.tar -C /volume"
docker run --rm -v prometheus-data:/volume -v $PWD/backup:/backup alpine sh -c "rm -rf /volume/* && tar -xvf /backup/prometheus-data.tar -C /volume"


# Step 4: Create a network
# note: delete network if it's already there
docker network rm network
docker network create network

# Step 5: Run docker-compose:: (1) spins up jenkins
# docker run -d --name jenkins --network network -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v jenkins-data:/jenkins-data -v jenkins-docker-certs:/certs/client my-jenkins && docker logs -f jenkins
cd "$ROOT_PWD"
cd jenkins/
# docker build -t my-jenkins .
docker pull --platform linux/arm64 rspearscmu/devops-final:jenkins
# rename to my-jenkins
docker tag rspearscmu/devops-final:jenkins my-jenkins

docker compose --verbose up --build
docker compose --verbose up -d # runs on detached mode
# docker compose logs -f  # follow logs



# Perform clean up
# docker compose --verbose down



