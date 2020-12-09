# Copyright (c) 2020, Oracle and/or its affiliates.

only=$1

case $only in
    server) server=1; router=0; shell=0 ;;
    router) server=0; router=1; shell=0 ;;
    shell) server=0; router=0; shell=1 ;;
    *) server=1; router=1; shell=1 ;;
esac

version1=8.0.21
version0=8.0.20

DOCKER_IMAGE_DIR=${DOCKER_IMAGE_DIR:-/tmp/docker-images}
mkdir -p $DOCKER_IMAGE_DIR

function build() {
    cmd=$1
    repo=$2
    image=$3
    ver=$4

    echo
    echo "$repo/$image:$ver"
    echo
    image_id=$($cmd $repo $ver| tee /dev/fd/2 | grep 'Successfully built'|cut -d\  -f3)
    if test "$image_id" = ""; then
        echo "Build failed"
        exit 1
    fi

    docker push $repo/$image:$ver
}

repo=iad.ocir.io/mysql2/shell

if [ $server -ne 0 ]; then
    build ./make_server.sh $repo mysql-server $version1
    build ./make_server.sh $repo mysql-server $version0
fi

if [ $shell -ne 0 ]; then
    build ./make_shell.sh $repo mysql-shell $version1
fi

if [ $router -ne 0 ]; then
    build ./make_router.sh $repo mysql-router $version1
    build ./make_router.sh $repo mysql-router $version0
fi

