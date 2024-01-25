#!/bin/bash

# 定义ETCD集群的成员名称
NODE1=etcd-node1
NODE2=etcd-node2
NODE3=etcd-node3

# 创建一个网络
docker network create etcd-network

# 创建卷
docker volume create etcd-data-node1
docker volume create etcd-data-node2
docker volume create etcd-data-node3

# 启动ETCD集群的第一个节点
docker run -d \
  --net etcd-network \
  --name $NODE1 \
  -p 12379:2379 \
  --volume=etcd-data-node1:/etcd-data \
  quay.io/coreos/etcd:latest \
  /usr/local/bin/etcd \
  --name $NODE1 \
  --data-dir=/etcd-data \
  --listen-client-urls http://0.0.0.0:2379 \
  --advertise-client-urls http://$NODE1:2379 \
  --listen-peer-urls http://0.0.0.0:2380 \
  --initial-advertise-peer-urls http://$NODE1:2380 \
  --initial-cluster $NODE1=http://$NODE1:2380,$NODE2=http://$NODE2:2380,$NODE3=http://$NODE3:2380 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-cluster-state new

# 启动ETCD集群的第二个节点
docker run -d \
  --net etcd-network \
  --name $NODE2 \
  -p 22379:2379 \
  --volume=etcd-data-node2:/etcd-data \
  quay.io/coreos/etcd:latest \
  /usr/local/bin/etcd \
  --name $NODE2 \
  --data-dir=/etcd-data \
  --listen-client-urls http://0.0.0.0:2379 \
  --advertise-client-urls http://$NODE2:2379 \
  --listen-peer-urls http://0.0.0.0:2380 \
  --initial-advertise-peer-urls http://$NODE2:2380 \
  --initial-cluster $NODE1=http://$NODE1:2380,$NODE2=http://$NODE2:2380,$NODE3=http://$NODE3:2380 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-cluster-state new

# 启动ETCD集群的第三个节点
docker run -d \
  --net etcd-network \
  --name $NODE3 \
  -p 32379:2379 \
  --volume=etcd-data-node3:/etcd-data \
  quay.io/coreos/etcd:latest \
  /usr/local/bin/etcd \
  --name $NODE3 \
  --data-dir=/etcd-data \
  --listen-client-urls http://0.0.0.0:2379 \
  --advertise-client-urls http://$NODE3:2379 \
  --listen-peer-urls http://0.0.0.0:2380 \
  --initial-advertise-peer-urls http://$NODE3:2380 \
  --initial-cluster $NODE1=http://$NODE1:2380,$NODE2=http://$NODE2:2380,$NODE3=http://$NODE3:2380 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-cluster-state new

echo "ETCD集群创建完成。"