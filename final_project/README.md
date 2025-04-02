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
docker run --rm --network jenkins -t ghcr.io/zaproxy/zaproxy:stable     zap-baseline.py -t http://192.168.64.3:8080 -I > zap-results.txt
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




