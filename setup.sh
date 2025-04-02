#!/bin/bash

ROOT_PWD=$PWD
# pre-installation
# Step 1: Curl zip 
echo "------- Starting Setup -------"
mkdir -p backup
cd backup
echo "------- donwloading final_devops from google drive ---------"
pip3 install gdown
gdown 1SCn5TG1KIn2Za0plufOoh4FnknzUDdp6
echo "------- unzipping devops file ---------"
unzip final_devops.zip

echo "---- Installing all other dependencies---"
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \\
    apt-get update && \\
    apt-get install -y \\
    openjdk-17-jdk \\
    sshpass \\
    ansible \\
    apt-transport-https \\
    ca-certificates \\
    curl \\
    software-properties-common \\
    lsb-release \\
    gnupg \\
    nodejs && \\
    apt-get clean && \\
    rm -rf /var/lib/apt/lists/*

echo "------- moving all tar files to final_devops ---------"
# move all tar files from final_devops folder into current backup
mv final_devops/* .

# Step 2: Create volumes
echo "------- Creating all necessary volumes ---------"
docker volume create jenkins-data
docker volume create jenkins_home
docker volume create jenkins-docker-certs
docker volume create grafana-storage
docker volume create prometheus-data

cd "$ROOT_PWD"

# Step 3: Untar + Upload / Restore volume
echo "------- Performing untar and hooking up to volumes ---------"
docker run --rm -v jenkins_home:/volume -v $PWD/backup:/backup alpine sh -c "rm -rf /volume/* && tar -xvf /backup/jenkins_home.tar -C /volume"
docker run --rm -v jenkins-data:/volume -v $PWD/backup:/backup alpine sh -c "rm -rf /volume/* && tar -xvf /backup/jenkins-data.tar -C /volume"
docker run --rm -v jenkins-docker-certs:/volume -v $PWD/backup:/backup alpine sh -c "rm -rf /volume/* && tar -xvf /backup/jenkins-docker-certs.tar -C /volume"
docker run --rm -v grafana-storage:/volume -v $PWD/backup:/backup alpine sh -c "rm -rf /volume/* && tar -xvf /backup/grafana-storage.tar -C /volume"
docker run --rm -v prometheus-data:/volume -v $PWD/backup:/backup alpine sh -c "rm -rf /volume/* && tar -xvf /backup/prometheus-data.tar -C /volume"


# Step 4: Create a network
# note: delete network if it's already there
echo "------- Creating a common docker network ---------"
docker network rm network
docker network create network

# Step 5: Run docker-compose:: (1) spins up jenkins
# docker run -d --name jenkins --network network -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v jenkins-data:/jenkins-data -v jenkins-docker-certs:/certs/client my-jenkins && docker logs -f jenkins
cd "$ROOT_PWD"
cd jenkins/

echo "------- Building jenkins according to type of arch platform ---------"
# Detect architecture
ARCH=$(uname -m)
echo "Detected architecture: $ARCH"
# Select appropriate Dockerfile based on architecture
if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
    echo "Building for ARM64 architecture..."
    JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk-arm64"
    docker pull --platform linux/arm64 rspearscmu/devops-final:jenkins
    # rename to my-jenkins
    docker tag rspearscmu/devops-final:jenkins my-jenkins
    DOCKER_ARCH="arm64"
elif [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
    echo "Building for x86_64/AMD64 architecture..."
    JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk-amd64"
    docker build -t my-jenkins -f Dockerfile.intel .
    DOCKER_ARCH="amd64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

echo "------- Running Docker Compose ---------"
docker compose --verbose up --build
docker compose --verbose up -d # runs on detached mode
docker compose logs -f  # follow logs
