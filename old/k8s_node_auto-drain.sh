#!/bin/sh
#
# drains a "NotReady" nodes and uncordons "Ready"
# requires kubectl access to the cluster, 
# add cronjob
# * * * * * /root/k8s_node_auto-drain.sh

KUBECTL="/usr/bin/kubectl"

# Get only nodes which are not drained yet
NOT_READY_NODES=$($KUBECTL get nodes | grep -P 'NotReady(?!,SchedulingDisabled)' | awk '{print $1}' | xargs echo)
# Get only nodes which are still drained
READY_NODES=$($KUBECTL get nodes | grep '\sReady,SchedulingDisabled' | awk '{print $1}' | xargs echo)

if [ ! -z "$NOT_READY_NODES" ]
then
        date >> /var/log/k8s_pods_status ;
        echo "Unready nodes that are undrained: $NOT_READY_NODES" >> /var/log/k8s_pods_status
fi
#echo "Ready nodes: $READY_NODES"


for node in $NOT_READY_NODES; do
  echo "Node $node not drained yet, draining..."  >>/var/log/k8s_pods_status
  $KUBECTL drain --ignore-daemonsets --delete-local-data --force --grace-period=0 --timeout=10s $node
#  echo "Done"
done;

for node in $READY_NODES; do
  echo "Node $node is ready, uncordoning..."  >>/var/log/k8s_pods_status
  $KUBECTL uncordon $node
#  echo "Done"
done;
