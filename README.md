<br />
<p align="center">
    <img src="https://avatars.githubusercontent.com/u/9037579?v=4"/>
    <h3 align="center">Juno VCluster Builder</h3>
    <p align="center">
        Creates a VCluster in a running cluster and imports it into ArgoCD in the same cluster.
    </p>
</p>

## Dependencies

- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/)

## Usage

Meant to be run as a Kubernetes based Job. The Cluster Builder will create an isolated vcluster that will be imported 
into ArgoCD. This will allow for the creation of a project hub that can be used to deploy other Juno services. 

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: <show code>
  namespace: <argocd namespace>
  annotations:
    argocd.argoproj.io/hook: Sync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  backoffLimit: 1
  template:
    spec:
      nodeSelector:
        kubernetes.io/arch: amd64
      restartPolicy: Never
      serviceAccountName: cluster-builder
      containers:
        - name: <show code>
          image: aldmbmtl/cluster-builder:v0.0.1
          imagePullPolicy: Always
          env:
            - name: ACTION
              value: "install" or "uninstall"
            - name: NAME
              value: <show code>
```

If this passes, the annotations will trigger the ArgoCD to sync the new vcluster and then auto delete the job.

```yaml
annotations:
    argocd.argoproj.io/hook: Sync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
```

### Juno Project Hub

Please reference the [Juno Project Hub](https://github.com/juno-fx/Project-Hub) for more information on how to properly
deploy and set up a project.

