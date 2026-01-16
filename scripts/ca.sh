#!/bin/bash

# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.19.2/cert-manager.yaml || (echo "failure installing cert-manager; aborting"; exit 1)

# Install istio
istioctl install || (echo "failure installing istio"; exit 2)


# Configuration
DOMAIN="test.local"
NAMESPACE="istio-system"

echo "1. Generating CA Key and Certificate..."
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt \
    -subj "/C=US/ST=State/L=City/O=Development/CN=My Cert-Manager CA"

echo "2. Uploading CA to Kubernetes as a Secret..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic manual-ca-secret \
    --namespace $NAMESPACE \
    --from-file=tls.crt=ca.crt \
    --from-file=tls.key=ca.key \
    --dry-run=client -o yaml | kubectl apply -f -

echo "3. Creating cert-manager Issuer and Certificate..."
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: local-ca-issuer
  namespace: $NAMESPACE
spec:
  ca:
    secretName: manual-ca-secret
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: wildcard-test-local
  namespace: $NAMESPACE
spec:
  secretName: wildcard-certs
  duration: 2160h # 90 days
  renewBefore: 360h # 15 days
  subject:
    organizations:
      - development
  commonName: "*.$DOMAIN"
  isCA: false
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
  usages:
    - server auth
    - client auth
  dnsNames:
    - "*.$DOMAIN"
    - "$DOMAIN"
  issuerRef:
    name: local-ca-issuer
    kind: Issuer
    group: cert-manager.io
EOF

echo "------------------------------------------"
echo "Done!"
echo "Cert-manager is now managing the wildcard certificate."
echo "Secret 'wildcard-certs' will be generated automatically by cert-manager."