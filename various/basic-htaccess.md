# Howto add basic http auth

[https://kubernetes.github.io/ingress-nginx/examples/auth/basic/](https://kubernetes.github.io/ingress-nginx/examples/auth/basic/)

### create passwd

```
htpasswd -c auth user
```

### Convert htpasswd into a secret
```
kubectl create secret generic graph-auth --from-file=auth --namespace=cattle-monitoring-system
```

### Examine secret
```
kubectl get secret basic-auth -o yaml
```

### Using kubectl, create an ingress tied to the basic-auth secret

```
$ echo "
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-with-auth
  annotations:
    # type of authentication
    nginx.ingress.kubernetes.io/auth-type: basic
    # name of the secret that contains the user/password definitions
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    # message to display with an appropriate context why the authentication is required
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required - foo'
spec:
  ingressClassName: nginx
  rules:
  - host: foo.bar.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service: 
            name: http-svc
            port: 
              number: 80
" | kubectl create -f -
```


