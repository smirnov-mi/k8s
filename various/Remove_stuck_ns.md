# some useful howtos

## k8s stuck namespaces

to remove stuck namespace:

```

NS=p-bld4k

kubectl get namespace $NS -o json  | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/"  | kubectl replace --raw /api/v1/namespaces/$NS/finalize -f -

```

