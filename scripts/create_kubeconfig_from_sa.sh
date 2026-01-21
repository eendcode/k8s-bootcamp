#!/bin/bash

mkdir -p ~/.kube
cat <<EOF > ~/.kube/config
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    server: https://kubernetes.default.svc
  name: in-cluster
contexts:
- context:
    cluster: in-cluster
    namespace: $(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
    user: code-server-sa
  name: in-cluster-context
current-context: in-cluster-context
users:
- name: code-server-sa
  user:
    tokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
EOF