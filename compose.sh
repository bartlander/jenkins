#!/usr/bin/env bash

set -e

#env="local"

rm -rf tmp
mkdir -p tmp
cp -r dfiles tmp

# Using $USERDOMAIN to distinguish internal/corporate and external - see also docker-entrypoint.sh.
if [[ ! "$USERDOMAIN" == "" ]]; then
  echo "Corporate environment detected"
  echo "  * Ensure all DKR_CNTLM_... env vars are defined properly in the env file"
else
  echo "External environment detected"
  echo "  * Assuming running on docker host"
  export DKR_HOST_UID=$(id -u jenkins)
  export DKR_HOST_GID=$(getent group docker | cut -d: -f3)
fi
if [[ ! "$DKR_CNTLM_TLSCERTS_DIR" == "" ]]; then
  if [[ -e "$DKR_CNTLM_TLSCERTS_DIR" ]]; then
    echo "cp '$DKR_CNTLM_TLSCERTS_DIR'/* ./tmp/dfiles/usr/local/share/ca-certificates"
    cp "$DKR_CNTLM_TLSCERTS_DIR"/* ./tmp/dfiles/usr/local/share/ca-certificates;
  fi
fi

docker image prune -f
docker container stop jenkins > /dev/null 2>&1 || { :; }
docker container rm jenkins > /dev/null 2>&1 || { :; }
docker image rm -f jenkins > /dev/null 2>&1 || { :; }
#docker volume rm jenkins_home > /dev/null 2>&1 || { :; }
if [[ "$1" == "-" ]]; then
  echo "docker image rm -f jenkins-staging"; echo "Are you sure? Do it manually."
  #docker image rm -f jenkins-staging || { :; }
  exit 1
fi

docker image ls | grep jenkins-staging || {
  docker build -f Dockerfile-staging -t jenkins-staging .
}

#docker compose up -d
cp env .env
docker compose config
docker compose create
docker start jenkins

sleep 5
docker logs jenkins
docker exec -it jenkins bash -c "docker version"
docker exec -it -u root jenkins bash -c "ps -fA"
