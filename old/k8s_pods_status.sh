#!/bin/bash
# requires kubectl access.
# add a cronjob
# */5 * * * * /root/k8s_pods_status.sh
/usr/bin/kubectl get po --all-namespaces -o wide |egrep -v "NAME|Running|Completed|Creating| 0s| 1s| 2s" | while IFS= read -r line; do printf '%s %s\n' "$(date)" "$line"; done >>/var/log/k8s_pods_status
/usr/bin/kubectl get no -o wide |egrep -v "INTERNAL-IP|Ready " | while IFS= read -r line; do printf '%s %s\n' "$(date)" "$line"; done >>/var/log/k8s_pods_status
touch /var/log/k8s_pods_status
