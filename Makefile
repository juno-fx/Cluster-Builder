# vars
PY="python3.8"
VENV="venv/bin"
PIP="$(VENV)/pip3"
PROJECT="avi"

# targets
_deploy_argo:
	@kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@sleep 20
	@kubectl wait --namespace argocd \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/name=argocd-server \
		--timeout=90s

dependencies:
	@kubectl create namespace argocd && $(MAKE) --no-print-directory _deploy_argo || echo "ArgoCD already installed..."

cluster:
	@kind create cluster --name $(PROJECT) || echo "Cluster already exists..."
	@$(MAKE) --no-print-directory dependencies

down:
	@kind delete cluster --name $(PROJECT)

# testing
_run_tests:
	# Build the required artifacts and export them to the
	# build file for use in the next steps
	@skaffold build --file-output build.json

	# Create the cluster if it doesn't exist
	@$(MAKE) --no-print-directory cluster || echo "Cluster already exists..."

	# Force load images into the cluster
	@skaffold deploy -a build.json --load-images=true

	# Run the tests
	@skaffold verify -a build.json

argo:
	@echo "Admin Password: $(shell kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)"
	@echo "ArgoCD Server: https://localhost:8080/settings/clusters"
	@kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1

test:
	@echo "Tests... Cluster will be taken down after"
	@$(MAKE) --no-print-directory _run_tests || (echo "Tests failed!" \
		&& rm -rf build.json) \
		&& (echo "Tests passed!" \
		&& rm -rf build.json)

ci-test:
	@echo "Tests... Cluster will be taken down after"
	@$(MAKE) --no-print-directory _run_tests || (echo "Tests failed!" \
		&& rm -rf build.json \
		&& $(MAKE) --no-print-directory down \
		&& exit 1) && (echo "Tests passed!" \
		&& rm -rf build.json \
		&& $(MAKE) --no-print-directory down \
		&& exit 0)
