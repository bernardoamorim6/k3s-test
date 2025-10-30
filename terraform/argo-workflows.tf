# Argo Workflows Installation
# Split into separate steps for reliability

# Step 1: Create namespace
resource "null_resource" "argo_namespace" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      export KUBECONFIG="${path.cwd}/output/kubeconfig.yaml"
      kubectl create namespace argo || true
    EOT
  }

  depends_on = [
    docker_container.k3s_server,
    docker_container.k3s_agent,
    null_resource.wait_for_kubeconfig
  ]
}

# Step 2: Install Argo Workflows
resource "null_resource" "install_argo_workflows" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      export KUBECONFIG="${path.cwd}/output/kubeconfig.yaml"
      
      echo "Installing Argo Workflows..."
      kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v3.5.12/install.yaml
      
      echo "Waiting for initial deployment..."
      sleep 10
      
      echo "Waiting for Workflow Controller to be ready..."
      kubectl wait --for=condition=available --timeout=300s deployment/workflow-controller -n argo
      
      echo "Argo Workflows base installation complete!"
    EOT
  }

  depends_on = [null_resource.argo_namespace]
}

# Step 3: Patch server for insecure mode AND fix readiness probe
resource "null_resource" "patch_argo_server" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      export KUBECONFIG="${path.cwd}/output/kubeconfig.yaml"
      
      echo "Patching Argo Server for insecure mode..."
      
      # Patch deployment with both insecure mode AND HTTP readiness probe
      kubectl patch deployment argo-server -n argo --type='json' -p='[
        {
          "op": "replace",
          "path": "/spec/template/spec/containers/0/args",
          "value": ["server", "--auth-mode=server", "--secure=false"]
        },
        {
          "op": "replace",
          "path": "/spec/template/spec/containers/0/readinessProbe/httpGet/scheme",
          "value": "HTTP"
        }
      ]'
      
      echo "Waiting for patched deployment to be ready..."
      kubectl wait --for=condition=available --timeout=300s deployment/argo-server -n argo
      
      echo "Argo Server patched successfully!"
    EOT
  }

  depends_on = [null_resource.install_argo_workflows]
}

# Step 4: Create ServiceAccount for workflows
resource "null_resource" "workflow_serviceaccount" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      export KUBECONFIG="${path.cwd}/output/kubeconfig.yaml"
      
      echo "Creating workflow service account..."
      
      cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: workflow
  namespace: argo
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: workflow
  namespace: argo
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "watch", "list", "create", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: workflow
  namespace: argo
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: workflow
subjects:
- kind: ServiceAccount
  name: workflow
  namespace: argo
EOF
      
      echo "Service account created!"
    EOT
  }

  depends_on = [null_resource.patch_argo_server]
}
