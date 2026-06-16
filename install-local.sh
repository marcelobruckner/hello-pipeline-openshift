#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-hello-pipeline}"

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

ensure_project() {
  if oc get project "$NAMESPACE" >/dev/null 2>&1; then
    oc project "$NAMESPACE" >/dev/null
  else
    oc new-project "$NAMESPACE" >/dev/null
  fi
}

main() {
  require oc

  echo "Using namespace: $NAMESPACE"
  ensure_project

  oc apply -f pipeline/06-serviceaccount.yaml
  oc apply -f pipeline/10-rbac-deploy.yaml
  oc apply -f pipeline/04-pvc.yaml
  oc apply -f pipeline/07-get-git-sha.yaml
  oc apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.9/git-clone.yaml
  oc apply -f pipeline/11-image-stream.yaml
  oc apply -f pipeline/12-buildconfig.yaml
  oc apply -f pipeline/13-build-openshift-image.yaml
  oc apply -f pipeline/08-deploy-openshift.yaml
  oc apply -f pipeline/03-pipeline.yaml

  echo "Installed. Start a manual run with:"
  echo "oc create -f run/05-run.yaml -n $NAMESPACE"
  echo "GitOps and webhook integration are intentionally deferred to the next phase."
}

main "$@"
