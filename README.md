# 17636 DevOps Final Project Submission

## Group Members

| Name          | AndrewID |
| ------------- | -------- |
| Ryan Spears   | rspears  |
| Christy Tseng | yuchingt |
| Nancy Lin     | yilingl2 |
| Watson Chao   | yinchuac |
| Iris Ting     |          |
| Royce Ang     | royceang |


## Issues Related To OWASP ZAP Permissions
To TAs:

We have consistently been running into a permission related issue pertaining to `OWASP Zap`. Specifically, `Permission denied: '/zap/wrk/`.
This is an impediment towards generating the `.html` file, which is one of the required deliverables. The `.html` file can be generated via:
```bash
docker run -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-stable zap-baseline.py \ -t https://www.example.com -g gen.conf -r testreport.html
```

This is a known issue within the community: https://github.com/zaproxy/zaproxy/issues/6993.

We have toiled days and nights over this and were not able to produce the `.html` version. However, we chose to ouput a `zap-results.txt` instead, which is similar to the `.html` version, albeit, a non user-friendly version of it.


## Step-By-Step Instructions: Provide detailed documentation outlining the steps to set up the environment and configure the DevSecOps pipeline.

Note to TAs: 

(1) All scripts can be found in the `Provisioning_Scripts_And_Configuration` folder.

(2) File Structure

```
Provisioning_Scripts_And_Configuration/
├── ansible/                        # Infrastructure automation (Ansible playbooks, roles, inventory)
│   └── inventory.yml               # Ansible inventory script
├── jenkins/                        # Jenkins configuration, jobs, pipelines
│   ├── docker-compose.yml          # Script to hook up Jenkins + Grafana + Prometheus + Sonarqube
│   ├── Dockerfile                  # Dockerfile to setup Jenkins image for Arms64 Arch
│   └── Dockefile.intel             # Dockerfile to setup Jenkins image for x86 Arch
├── volumes/                        # Pre-exported Docker volume archives
│   ├── grafana-storage.tar         # Grafana dashboards and settings
│   ├── jenkins-data.tar            # Jenkins home directory data
│   ├── jenkins-docker-certs.tar    # Docker client certificates for Jenkins
│   ├── prometheus-data.tar         # Prometheus TSDB data
│   ├── sonarqube_data.tar          # SonarQube project data
│   ├── sonarqube_extensions.tar    # SonarQube plugins/extensions
│   └── sonarqube_logs.tar          # SonarQube logs
├── clean_up.sh                     # Shell script to tear down or clean resources
├── deploy.yml                      # Deployment script to Deploy Spring PetClinic Without Docker
├── output.txt                      # Consolidated commands output log file (combined stdout/stderr)
└── setup.sh                        # Shell script to provision or bootstrap services
```

(3)  a `setup.sh` script is provided to setup the entire DevSecOps pipeline. The `setup.sh` is the entry point that provides an encapsulation of all the commands necessary for a successful deployment of the pipeline. This includes running the various DockerFiles and DockerCompose.

Additionally, to make configuration easy, most of the configurations were stored in its individual volume, which can be found in the `volumes/` folder.

------
**Step-By-Step Instructions Set Up**

Pre-requesite: Ensure that you have `pip3` installed.

```bash
# Step 1: Clone from this project
git clone https://github.com/dorryspears/spring-petclinic-group-project.git

# Step 2: cd to this project
cd spring-petclinic-group-project

# Step 3: run main script
chmod +x setup.sh

# Step 4: Run setup script
./setup.sh

# Step 5: Open Jenkins UI
# Jenkins URL: http://localhost:8080
# Jenkins automates the build, test, and deployment stages of the CI/CD pipeline.

# Step 6: Commit a change within the code and push to `main`
# This will trigger the DevSecOps pipeline EVERY 1 Minute via a poll-based Jenkins job.

# Step 7: Tooling Overview

# SonarQube: http://localhost:9000
# ➤ Static code analysis to detect bugs, vulnerabilities, and code smells in the application.

# Grafana: http://localhost:3000
# ➤ Real-time dashboard visualization for monitoring system metrics and pipeline health.

# Prometheus: http://localhost:9090
# ➤ Time-series monitoring system that collects metrics from the app and infrastructure for alerting and analysis.

#  OWASP ZAP: (Runs automatically — Artifact exported as .txt file)
# ➤ Performs dynamic application security testing (DAST) to find runtime web vulnerabilities like XSS, SQLi, etc.


# Ansible:: As part of the jenkins pipeline, Ansible playbook is invoked
# by consuming the following with its list of host specifications
deploy.yml # invoked file
inventory.ini # Host specifications

# These tools are automatically integrated into the DevSecOps pipeline during setup.
```

Note to TAs: `OWASP ZAP` has its own script integrated within the Jenkins pipeline, and there's NO need to run this manually.
```bash
# OWASP ZAP command line to generate the output artifact at
# the end of the jenkins pipeline
docker run --rm --network jenkins -t ghcr.io/zaproxy/zaproxy:stable     zap-baseline.py -t https://192.168.64.3:8080 -I > zap-results.txt
```

----
**Performing Clean Upt**

To facillitate the clean-up process, we have also provided the following
clean up script.

```bash
# run the following script from root of spring-petclinic-group-project/
chmod +x clean_up.sh
./clean_up.sh
```


----
**Details of setup.sh**
```bash
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
```


----
**Landing Page URLs**
- Jenkins: `http://localhost:8080`
- Sonarqube: `http://localhost:9000`
- Grafana: `http://localhost:3000`
- Prometheus: `http://localhost:9090`


---
### Additional Configurations (FYI)
- Jenkins: served via port `8080:8080`
- Grafana: served via port `3000:3000`
- Prometheus: served via port `9090:9090`
- Sonarqube: served via port `9000:9000`


## Other Deliverables
### Screenshot Folder Contains:
- spring-petclinic welcome screen on the production web server.
- Jenkins screen.
- SonarQube screen.
- Prometheus screen.
- Grafana screen.
- OWASP ZAP `zap-result.txt` file.
- Evidence of code change triggers the pipeline, deployment is done, and the content of the application is automatically updated.

### Pipeline Demonstration Folder:
- The `youtube link` which showcases the demonstration of the DevSecOps pipeline being triggered can be found in the `.txt` file in the `VideoDemonstration` folder.



