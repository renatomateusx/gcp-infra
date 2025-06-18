#!/bin/bash

set -e

# 1. Create namespace if it doesn't exist
kubectl create namespace dynatrace --dry-run=client -o yaml | kubectl apply -f -

# 2. Add Helm repository
helm repo add dynatrace https://helm.dynatrace.com
helm repo update

# 3. Install Dynatrace Operator
helm install dynatrace-operator dynatrace/dynatrace-operator \
  --namespace dynatrace \
  --create-namespace \
  -f dynatrace-values.yaml

# 4. Apply the Dynakube CR
kubectl apply -f dynakube.yaml
