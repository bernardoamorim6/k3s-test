# What's a namespace?
# • A virtual cluster inside your cluster
# • Isolates resources (like folders for files)
# • Argo CD resources live in the argocd namespace
# • Prevents name conflicts with other apps

# Create argocd namespace
resource "null_resource" "argocd_namespace" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      export KUBECONFIG="${path.cwd}/output/kubeconfig.yaml"
      kubectl create namespace argocd
    EOT
  }

  #   Why depends_on?
  # • Ensures the k3s cluster is fully running first
  # • Waits for kubeconfig file to exist
  # • Prevents connection errors

  depends_on = [
    docker_container.k3s_server,
    docker_container.k3s_agent,
    null_resource.wait_for_kubeconfig
  ]

  triggers = {
    server_id = docker_container.k3s_server[0].id
  }
}

# Why null_resource with local-exec?
# • The manifest is too large for kubectl_manifest resource
# • local-exec runs a command on your machine
# • kubectl apply handles all 30 resources correctly
# • kubectl wait pauses until Argo CD is ready

# Install Argo CD
resource "null_resource" "install_argocd" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    #     What kubectl apply does:
    # 1. Reads the YAML file
    # 2. Parses it into 30+ separate resources
    # 3. Sends each to the Kubernetes API
    # 4. Kubernetes creates pods, services, etc.
    # 5. Docker pulls container images
    # 6. Containers start running
    command = <<-EOT
      export KUBECONFIG="${path.cwd}/output/kubeconfig.yaml"
      echo "Installing Argo CD..."
      kubectl apply -n argocd -f argocd-install.yaml
      echo "Waiting for Argo CD to be ready..."
      kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd || true
    EOT
  }

  depends_on = [null_resource.argocd_namespace]

  triggers = {
    server_id = docker_container.k3s_server[0].id
  }
}
