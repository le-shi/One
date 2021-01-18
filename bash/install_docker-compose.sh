#!/bin/bash
compose_path=/usr/bin/docker-compose

if [[ ! -f ${compose_path} ]]; then
    curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o ${compose_path}
    chmod +x ${compose_path}
else
    echo
    echo "Is already installed. Path: $(type docker-compose)"
    echo
fi

if [[ ! -x ${compose_path} ]]; then
    chmod +x ${compose_path}
fi

# 输出docker-compose版本
docker-compose --version