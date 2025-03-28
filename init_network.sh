#!/bin/bash

docker network rm traefik-network || true  

docker network create \
    --driver overlay \
    --attachable \
    traefik-network
