#!/bin/bash

# 获取当前日期作为TAG
DATE_TAG=$(date +%Y%m%d)

# 定义镜像名称
IMAGE_NAME="my-go-app"

# 构建Docker镜像
docker build -t ${IMAGE_NAME}:${DATE_TAG} .

# 运行容器
# 确保使用与ETCD集群相同的Docker网络
NETWORK="etcd-network"
CONTAINER_NAME="my-go-app-${DATE_TAG}"

docker run -d --net ${NETWORK} -p 8080:8080 --name ${CONTAINER_NAME} ${IMAGE_NAME}:${DATE_TAG}

echo "Docker container ${CONTAINER_NAME} started using image ${IMAGE_NAME}:${DATE_TAG}"

docker images
docker ps