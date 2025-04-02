#!/bin/bash

# rm docker network if there is
cd jenkins
docker compose --verbose down
docker network rm network

