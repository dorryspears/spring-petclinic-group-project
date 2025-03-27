#!/bin/bash

ROOT_PWD=$PWD
cd jenkins
docker-compose down 
docker image rm my-jenkins
docker network rm network
