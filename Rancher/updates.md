# Latest news on work with Rancher

## Rancher updates

18.5.2024 Rancher v2.8.3 -> v2.8.4 (check https://github.com/rancher/rancher for latest version)

### Upgrade a single docker installation

https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/other-installation-methods/rancher-on-a-single-node-with-docker/upgrade-docker-installed-rancher

```bash
docker stop <RANCHER_CONTAINER_NAME>
docker create --volumes-from <RANCHER_CONTAINER_NAME> --name rancher-data rancher/rancher:<RANCHER_CONTAINER_TAG>
docker run --volumes-from rancher-data -v "$PWD:/backup" --rm busybox tar zcvf /backup/rancher-data-backup-<RANCHER_VERSION>-<DATE>.tar.gz /var/lib/rancher

docker pull rancher/rancher:<RANCHER_VERSION_TAG>

# Start Docker from the new image
docker run .....

# Remove the previous Rancher server container. If you only stop the previous Rancher server container (and don't remove it), the container may restart after the next server reboot.

```




## Updating RKE cluster


11.06.2024 : updating RKE Cluster k8s 1.28.9-rancher1-1 -> 1.28.10-rancher1-1

```bash
NAME STATUS ROLES                   AGE VERSION INTERNAL-IP EXTERNAL-IP   OS-IMAGE    KERNEL-VERSION      CONTAINER-RUNTIME
t1-1 Ready controlplane,etcd,worker 3d v1.28.10   1.2.3.4  <none> Ubuntu 22.04.4 LTS  5.15.0-112-generic docker://26.1.4
t1-2 Ready controlplane,etcd,worker 3d v1.28.10   1.2.3.5  <none> Ubuntu 22.04.4 LTS  5.15.0-112-generic docker://26.1.4
t1-3 Ready controlplane,etcd,worker 3d v1.28.10   1.2.3.6  <none> Ubuntu 22.04.4 LTS  5.15.0-112-generic docker://26.1.4
```



16.05.2024 : updating RKE Cluster k8s 1.28.8 -> 1.28.9

```bash
NAME STATUS ROLES                    AGE  VERSION INTERNAL-IP EXTERNAL-IP  OS-IMAGE      KERNEL-VERSION     CONTAINER-RUNTIME
t3-1 Ready  controlplane,etcd,worker 19d  v1.28.9   1.2.3.4  <none>  Ubuntu 22.04.4 LTS  5.15.0-105-generic  docker://24.0.9
t3-2 Ready  controlplane,etcd,worker 17d  v1.28.9   1.2.3.5  <none>  Ubuntu 22.04.4 LTS  5.15.0-105-generic  docker://24.0.9
t3-3 Ready  controlplane,etcd,worker 19d  v1.28.9   1.2.3.6  <none>  Ubuntu 22.04.4 LTS  5.15.0-105-generic  docker://24.0.9

```



