docker exec -it etcd-node1 /bin/sh

export ETCDCTL_API=3

etcdctl user add root

etcdctl auth enable

exit