#!/bin/bash

if [ "$ACTION" = "install" ]; then
  echo "Installing vcluster"
  sed -i "s/NAME/$NAME/g" vcluster-template.yaml
  vcluster create "$NAME" -n "$NAME" -f vcluster-template.yaml --connect=false --upgrade
  vcluster connect "$NAME" -n "$NAME" --update-current=false --server=https://avi.avi.svc.cluster.local
  argocd login argocd-server.argocd.svc.cluster.local --core
  argocd cluster add vcluster_"$NAME"_"$NAME"_ --name "$NAME" --yes --kubeconfig ./kubeconfig.yaml --upsert
else
  echo "Uninstalling vcluster"
  vcluster delete "$NAME" -n "$NAME"
fi
