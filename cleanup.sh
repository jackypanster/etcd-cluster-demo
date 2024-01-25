#!/bin/bash

# 获取当前日期作为TAG
DATE_TAG=$(date +%Y%m%d)

# 定义镜像和容器名称
IMAGE_NAME="my-go-app"
CONTAINER_NAME="my-go-app-${DATE_TAG}"

# 停止并删除容器
if [ $(docker ps -a -q -f name=${CONTAINER_NAME}) ]; then
    echo "Stopping and removing container ${CONTAINER_NAME}..."
    docker stop ${CONTAINER_NAME}
    docker rm ${CONTAINER_NAME}
else
    echo "No container found with name ${CONTAINER_NAME}"
fi

# 删除镜像
if [ $(docker images -q ${IMAGE_NAME}:${DATE_TAG}) ]; then
    echo "Removing image ${IMAGE_NAME}:${DATE_TAG}..."
    docker rmi ${IMAGE_NAME}:${DATE_TAG}
else
    echo "No image found with tag ${IMAGE_NAME}:${DATE_TAG}"
fi

echo "Cleanup complete."
docker images
docker ps