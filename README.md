# docker-sits

A conversion, from Packer to Puppet to Docker, of my work automating the provisioning of [SITS](https://www.tribalgroup.com/software-and-services/student-information-systems/sitsvision/) environments at the University of Sydney.

Notes to get started;
```
kubectl create -f sits-kubernetes.yaml
kubectl get all --namespace=sits
kubectl get pv --namespace=sits
kubectl get pvc --namespace=sits
kubectl describe pod --namespace=sits
docker container ls
docker exec -it abc /bin/bash
kubectl delete -f sits-kubernetes.yaml
```
