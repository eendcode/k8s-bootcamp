#!/bin/bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
helm install --replace falco --namespace falco --create-namespace --set tty=true --set falcosidekick.enabled=true --set falcosidekick.webui.enabled=true falcosecurity/falco
kubectl wait pods --for=condition=Ready --all -n falco