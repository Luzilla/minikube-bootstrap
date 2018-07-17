#!/usr/bin/env bash

minikube config set memory 8192

minikube start \
--vm-driver=hyperkit \
--logtostderr \
--loglevel 0 \
--stderrthreshold 0 \
--cache-images \
--bootstrapper=kubeadm \
--extra-config=apiserver.authorization-mode=RBAC \
--iso-url=./minikube-v0.28.0.iso

echo "Minikube started"

ingress_enabled=$(minikube addons list|grep ingress|grep enabled|wc -l)
if [ $ingress_enabled -gt 0 ]; then
  minikube addons disable ingress
  echo "Disabled ingress"
fi

echo "Setup helm with RBAC"

kubectl create -f ./rbac-config.yaml

helm init --upgrade --service-account tiller

echo "helm configured/initialized"
