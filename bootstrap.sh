#!/usr/bin/env bash

#set -x

ENABLE_RBAC=false
ENABLE_INGRESS=false
ENABLE_DEBUG=false

while getopts ":r:i:h" opt; do
  case $opt in
    r)
      ENABLE_RBAC=true
      ;;
    i)
      ENABLE_INGRESS=true
      ;;
    h)
      echo "Run with the following (optional flags): ./bootstrap -i -r"
      echo " -i - Enables ingress"
      echo " -r - Enables RBAC"
      exit
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

minikube config set memory 8192

minikube start --vm-driver=hyperkit --loglevel 0 \
--bootstrapper=localkube \
--logtostderr \
--stderrthreshold 0
#--cache-images
#--iso-url=./minikube-v0.28.0.iso

echo "Minikube started"

ingress_enabled=$(minikube addons list|grep ingress|grep enabled|wc -l)
if [ $ingress_enabled -gt 0 ]; then
  minikube addons disable ingress
  echo "Disabled ingress"
fi

if [ "$ENABLE_INGRESS" = true ];
then
  minikube addons disable ingress
fi

if [ "$ENABLE_RBAC" = true ];
then
  echo "Setup helm with RBAC"
  kubectl create -f ./rbac-config.yaml
  helm init --upgrade --service-account tiller
fi

if [ "$ENABLE_RBAC" = false ];
then
  helm init --upgrade
fi



echo "helm configured/initialized"
