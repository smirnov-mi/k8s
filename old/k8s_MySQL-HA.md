# MySQL on k8s

07.07.2019  MySQL CLuster on k8s, using HELM charts

**OUTDATED**


## MySQL Cluster on k8s, using HELM charts

### Prerequisites

1. Kubernetes cluster
1. Helm
1. kubectl
1. Storageclass (e.g. openEBS



## Master-Slave-Slave  configuration
(Or Master only with "replicas: 1")

https://github.com/helm/charts/tree/master/incubator/mysqlha
https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/


```
mkdir tmp7 && cd tmp7
git clone https://github.com/smirnov-mi/charts.git

root@max2-master-01:~/tmp7/charts# vi incubator/mysqlha/values.yaml
```


### using local storage

Prepare local storage (if no automated provisioning available):
on all worker nodes: # mkdir /data 

```
root@max2-master-01:~/tmp7/charts# kubectl create -f /root/mysqlha_local_storage_x2.yaml

root@max2-master-01:~/tmp7/charts# cat /root/mysqlha_local_storage_x3.yaml

# Create the MySQL-HA data volumes
apiVersion: v1
kind: PersistentVolume
metadata:
  name: data-mysql-mysqlha-0
  namespace: mysql
  labels:
    name: data-mysql-mysqlha-0
    app: mysql-mysqlha
    component: mysqlha
#    release: mysqlha
spec:
  capacity:
    storage: 300Mi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: /data/pv-mysqlha-0
  claimRef:
    name: data-mysql-mysqlha-0
    namespace: mysql
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: data-mysql-mysqlha-1
  namespace: mysql
  labels:
    name: data-mysql-mysqlha-1
    app: mysql-mysqlha
    component: mysqlha
#    release: mysqlha
spec:
  capacity:
    storage: 300Mi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: /data/pv-mysqlha-1
  claimRef:
    name: data-mysql-mysqlha-1
    namespace: mysql
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: data-mysql-mysqlha-2
  namespace: mysql
  labels:
    name: data-mysql-mysqlha-2
    app: mysql-mysqlha
    component: mysqlha
#    release: mysqlha
spec:
  capacity:
    storage: 300Mi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: /data/pv-mysqlha-2
  claimRef:
    name: data-mysql-mysqlha-2
    namespace: mysql
    
```


### using openEBS


edit values.yaml

```
persistence:
  enabled: true
  ## If defined, storageClassName: <storageClass>
  ## If set to "-", storageClassName: "", which disables dynamic provisioning
  ## If undefined (the default) or set to null, no storageClassName spec is
  ##   set, choosing the default provisioner.  (gp2 on AWS, azure-disk on
  ##   Azure, standard on GKE, AWS & OpenStack)
  ##
  # storageClass: "-"
  storageClass: "openebs-cstor-sparse"
  accessModes:
  - ReadWriteOnce
  size: 1G
  annotations: {}

```


### Install Helm Chart:
```
root@max2-master-01:~/tmp7/charts# helm install --name mysql --namespace mysql incubator/mysqlha --tls
```


### check

```
root@max1-master-01:~/tmp1/helm-charts/incubator# kubectl -n mysql get po
NAME              READY   STATUS     RESTARTS   AGE
mysql-mysqlha-0   2/2     Running    0          112s
mysql-mysqlha-1   0/2     Init:0/2   0          8s

root@max1-master-01:~/tmp1/helm-charts/incubator# kubectl -n mysql get pvc
NAME                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS           AGE
data-mysql-mysqlha-0   Bound    pvc-6c052ad4-d2e3-11e9-8a41-9600002a139b   1G         RWO            openebs-cstor-sparse   118s
data-mysql-mysqlha-1   Bound    pvc-aa514109-d2e3-11e9-8a41-9600002a139b   1G         RWO            openebs-cstor-sparse   14s
```

**doublecheck the services!**

```
kubectl -n mysql get svc

root@max1-master-01:~/tmp1/helm-charts/incubator# kuget svc |grep mysql
mysql          mysql-mysqlha                              ClusterIP   10.102.226.8     <none>         3306/TCP                              25m
mysql          mysql-mysqlha-readonly                     ClusterIP   10.104.22.30     <none>         3306/TCP                              53m

root@max1-master-01:~/tmp1/helm-charts/incubator# kuget svc |grep dns
kube-system    kube-dns                                   ClusterIP   10.96.0.10       <none>         53/UDP,53/TCP,9153/TCP                67d

root@max1-master-01:~/tmp1/helm-charts/incubator# nslookup 10.102.226.8 10.96.0.10
8.226.102.10.in-addr.arpa       name = mysql-mysqlha.mysql.svc.cluster.local.
```

see the fix below


1. Obtain the root password:
```
    kubectl get secret --namespace mysql mysql-mysqlha -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo
	kubectl get secret --namespace mysql mysql-mysqlha -o jsonpath="{.data.mysql-replication-password}" | base64 --decode; echo
0Hf1ToGEnTW0
h9co0BcdGV6J
```

2. Run a pod to use as a client:

    kubectl run mysql-client --image=mysql:5.7.13 -it --rm --restart=Never -- /bin/bash

3. Open a connection to one of the MySQL pods

    mysql -h mysql-mysqlha-0.mysql-mysqlha -p


==============================




## Master-Master Configuration


https://towardsdatascience.com/high-availability-mysql-cluster-with-load-balancing-using-haproxy-and-heartbeat-40a16e134691
https://www.linode.com/docs/databases/mysql/configure-master-master-mysql-database-replication/
https://www.howtoforge.com/tutorial/mysql-master_master-replication-on-debian-jessie/



PLAN:
We will take mysqlha image from above, with TWO nodes, 
and adjust the replication so that each master works also as slave for the other one. 
We will need a k8s service with multiple endpoints (all our mysql db master pods), e.g. like phpldapadmin has


master> mkdir tmp7 && cd tmp7
master> git clone https://github.com/smirnov-mi/charts.git


prepare local storage:
root@max2-master-01:~/tmp7/charts# kubectl create -f /root/mysqlha_local_storage_x2.yaml


Changes in the chart:

        modified:   incubator/mysqlha/Chart.yaml
        modified:   incubator/mysqlha/templates/statefulset.yaml
        modified:   incubator/mysqlha/templates/svc.yaml
        modified:   incubator/mysqlha/values.yaml

```
root@max2-master-01:~/tmp7/charts# git diff


diff --git a/incubator/mysqlha/templates/statefulset.yaml b/incubator/mysqlha/templates/statefulset.yaml
index d17b08720..6e0348e81 100644
--- a/incubator/mysqlha/templates/statefulset.yaml
+++ b/incubator/mysqlha/templates/statefulset.yaml
@@ -65,13 +65,13 @@ spec:
             # Copy server-id.conf adding offset to avoid reserved server-id=0 value.
             cat /mnt/config-map/server-id.cnf | sed s/@@SERVER_ID@@/$((100 + $ordinal))/g > /mnt/conf.d/server-id.cnf
             # Copy appropriate conf.d files from config-map to config mount.
-            if [[ $ordinal -eq 0 ]]; then
+            if [[ $ordinal -lt 2 ]]; then
               cp -f /mnt/config-map/master.cnf /mnt/conf.d/
             else
               cp -f /mnt/config-map/slave.cnf /mnt/conf.d/
             fi
             # Copy replication user script
-            if [[ $ordinal -eq 0 ]]; then
+            if [[ $ordinal -lt 2 ]]; then
               cp -f /mnt/config-map/create-replication-user.sh /mnt/scripts/create-replication-user.sh
               chmod 700 /mnt/scripts/create-replication-user.sh
             fi
diff --git a/incubator/mysqlha/values.yaml b/incubator/mysqlha/values.yaml
index a4eadca27..3cfff553d 100644
--- a/incubator/mysqlha/values.yaml
+++ b/incubator/mysqlha/values.yaml
@@ -62,7 +62,7 @@ persistence:
   # storageClass: "-"
   accessModes:
   - ReadWriteOnce
-  size: 10Gi
+  size: 300Mi
   annotations: {}
```
 resources:


```
root@max2-master-01:~/tmp7/charts# helm install --name mysql --namespace mysql incubator/mysqlha --tls


Verify running pods:
root@max2-master-01:~/tmp7/charts# kuget po |grep mysql
mysql          mysql-mysqlha-0                                          2/2     Running   0          81s
mysql          mysql-mysqlha-1                                          2/2     Running   0          58s
```

```
root@max2-master-01:~/tmp7/charts# kubectl get secret --namespace mysql mysql-mysqlha -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo
TW41v9iWt3O8
root@max2-master-01:~/tmp7/charts# kubectl get secret --namespace mysql mysql-mysqlha -o jsonpath="{.data.mysql-replication-password}" | base64 --decode; echo
anpQFHnd8fdm
```

GET names:
```
root@max2-master-01:~/tmp7/charts# kugetw po |grep mysql
mysql mysql-mysqlha-0 2/2     Running   0          14h   10.244.5.148     max2-worker-03   <none>           <none>
mysql mysql-mysqlha-1 2/2     Running   0          14h   10.244.3.195     max2-worker-02   <none>           <none>

root@max2-master-01:~/tmp7/charts# nslookup 10.244.5.148 10.96.0.10
148.5.244.10.in-addr.arpa       name = mysql-mysqlha-0.mysql-mysqlha.mysql.svc.cluster.local.

root@max2-master-01:~/tmp7/charts# nslookup 10.244.3.195 10.96.0.10
195.3.244.10.in-addr.arpa       name = mysql-mysqlha-1.mysql-mysqlha.mysql.svc.cluster.local.
```


SETUP REPLICATION. THIS MUST BE DONE MANUALLY AFTER EACH RESTART.

MASTER-0:
```
root@max2-master-01:~# kubectl exec -ti -n mysql mysql-mysqlha-0 bash

root@mysql-mysqlha-0:/# mysql -u root -p
Enter password:
mysql> show master status;
+----------------------------+----------+--------------+------------------+-------------------+
| File                       | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+----------------------------+----------+--------------+------------------+-------------------+
| mysql-mysqlha-0-bin.000003 |      790 |              |                  |                   |
+----------------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)

mysql> GRANT REPLICATION SLAVE ON *.* TO 'repl'@'mysql-mysqlha-1.mysql-mysqlha.mysql.svc.cluster.local.' IDENTIFIED BY 'anpQFHnd8fdm';
```


MASTER-1:
```
root@max2-master-01:~# kubectl exec -ti -n mysql mysql-mysqlha-1 bash
root@mysql-mysqlha-1:/# mysql -u root -p
mysql> show master status;
+----------------------------+----------+--------------+------------------+-------------------+
| File                       | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+----------------------------+----------+--------------+------------------+-------------------+
| mysql-mysqlha-1-bin.000001 |      531 |              |                  |                   |
+----------------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)

mysql> GRANT REPLICATION SLAVE ON *.* TO 'repl'@'mysql-mysqlha-0.mysql-mysqlha.mysql.svc.cluster.local.' IDENTIFIED BY 'anpQFHnd8fdm';
Query OK, 0 rows affected, 2 warnings (0.00 sec)


mysql> stop slave;
Query OK, 0 rows affected (0.01 sec)

mysql> CHANGE MASTER TO master_host='mysql-mysqlha-0.mysql-mysqlha.mysql.svc.cluster.local.', MASTER_USER='repl', MASTER_PASSWORD='anpQFHnd8fdm', MASTER_LOG_FILE='mysql-mysqlha-0-bin.000003', MASTER_LOG_POS=1118;
Query OK, 0 rows affected, 2 warnings (0.03 sec)

mysql> Start slave;
Query OK, 0 rows affected (0.01 sec)

mysql> SHOW MASTER STATUS;
+----------------------------+----------+--------------+------------------+-------------------+
| File                       | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+----------------------------+----------+--------------+------------------+-------------------+
| mysql-mysqlha-1-bin.000001 |      859 |              |                  |                   |
+----------------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)
```



Now do the same on master-0




see # of connections on your DB node:
```
mysql> show status like 'Con%';

see server id:
mysql> show variables where variable_name = 'server_id';




SLAVE-mysql> CHANGE MASTER TO MASTER_HOST=' mysql-mysqlha-1',MASTER_USER='repl', MASTER_PASSWORD='HNTGdbHTwdt5', MASTER_LOG_FILE=' mysql-mysqlha-1-bin.000001', MASTER_LOG_POS=04;
Query OK, 0 rows affected, 2 warnings (0.01 sec)
```
.....





double check the Service:

```
kubectl get svc -n mysql mysql-mysqlha
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
mysql-mysqlha   ClusterIP   10.96.249.144   <none>        3306/TCP   4m38s
```

**fix it if the it doesn't have CLUSTER-IP**
```
root@max2-master-01:~/tmp7/charts# kubectl get svc -n mysql mysql-mysqlha -o yaml > /tmp/mysqlha-svc.yaml
root@max2-master-01:~/tmp7/charts# vi /tmp/mysqlha-svc.yaml
root@max2-master-01:~/tmp7/charts# kubectl delete svc -n mysql mysql-mysqlha
service "mysql-mysqlha" deleted
root@max2-master-01:~/tmp7/charts# kubectl create -f /tmp/mysqlha-svc.yaml
```

### OPTIONAL: 
expose it to the external IP.


### TODO: 

DB Backups


Finalize sync configuration
make the sync configured automatically after pod restart



Multi-source replication

https://mysqlhighavailability.com/mysql-5-7-multi-source-replication-automatically-combining-data-from-multiple-databases-into-one/
https://dev.mysql.com/doc/refman/5.7/en/replication-multi-source.html


 