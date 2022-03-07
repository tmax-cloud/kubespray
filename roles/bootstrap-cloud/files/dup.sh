#!/bin/sh
set -e
src=$1
dst=$2
username=admin
password=admin

DOCKERCMD=docker
if [ $(command -v docker) ];
then
  DOCKERCMD=docker
fi

if [ $(command -v podman) ];
then
  DOCKERCMD=podman
fi

dup_image() {
    repo=${1#"\""}
    repo=${repo%"\""}
    tags=$(curl -s "http://$src/v2/$repo/tags/list" | jq '.tags | .[]')
    for tag in $tags
    do
        tag=${tag#"\""}
        tag=${tag%"\""}
        $DOCKERCMD pull "$src/$repo:$tag"
        $DOCKERCMD tag "$src/$repo:$tag" "$dst/library/$repo:$tag"
        $DOCKERCMD push "$dst/library/$repo:$tag"
    done
}

dup_repos() {
    repos=$(curl -s "http://$src/v2/_catalog" | jq '.repositories | .[]')
    for repo in $repos
    do
        dup_image $repo
    done
}

dup_repos