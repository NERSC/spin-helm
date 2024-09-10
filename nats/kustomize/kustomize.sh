#!/bin/bash

# Check if necessary environment variables are set
if [ -z "$SPIN_UID" ] || [ -z "$SPIN_GID" ]; then
  echo "Environment variables SPIN_UID and SPIN_GID must be set."
  exit 1
fi

# Substitute environment variables into the patch file
sed "s/RUN_AS_USER_PLACEHOLDER/$SPIN_UID/g" patch-statefulset.yaml | \
sed "s/FS_GROUP_PLACEHOLDER/$SPIN_GID/g" > patch-statefulset-substituted.yaml

sed "s/RUN_AS_USER_PLACEHOLDER/$SPIN_UID/g" patch-deployment.yaml | \
sed "s/FS_GROUP_PLACEHOLDER/$SPIN_GID/g" > patch-deployment-substituted.yaml

# Capture the Helm-rendered output
cat <&0 > all.yaml

# Run Kustomize with the substituted patch
kubectl kustomize ./ && rm all.yaml && rm *-substituted.yaml
