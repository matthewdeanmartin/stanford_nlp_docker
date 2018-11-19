#!/usr/bin/env bash
set -e

build_this()
{
    local NAME_TAG=$1

    docker build -t $NAME_TAG -t matthewdeanmartin/standford_nlp:latest .
    local TAG_PARTS=(${NAME_TAG//\// })
    docker images | grep ${TAG_PARTS[0]}
}
build_this matthewdeanmartin/standford_nlp:0.1.0

ssh_this()
{
    echo starting
    local NAME_TAG=$1
    local IMAGE_ID=$(docker images "$NAME_TAG" -q)
    echo "$IMAGE_ID"
    docker kill $(docker ps -q)


    docker run -dit -p 2222:22 -v /var/run/docker.sock:/var/run/docker.sock "$IMAGE_ID" && docker ps && ssh docker_base
}
# ssh_this matthewdeanmartin/standford_nlp:0.1.0

clean_up_containers()
{
    # remove all the containers.
    docker rm $(docker ps -a -q)
    docker ps -all
}

aggressively_clean_up_images(){
    # remove everything without a corresponding container.
    docker image prune -a
    docker images
}

run_this()
{
    local TAG=$1

    # docker run -it matthewdeanmartin/standford_nlp:"$TAG"
    redis-cli shutdown
    docker-compose up
}

attach_this()
{
    docker ps
    echo docker attach [id]
}

login_aws_docker()
{
    cat ~/.aws/credentials
    aws ecr get-login --no-include-email --region us-east-1 --profile prod
}

push_this()
{
    local TAG=$1

    docker tag matthewdeanmartin/standford_nlp:"$TAG" matthewdeanmartin/standford_nlp:"$TAG"
    docker push matthewdeanmartin/standford_nlp:"$TAG"
}
# push_this 0.1.1
