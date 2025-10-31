# Why do we need this?
# • k3s takes a few seconds to start
# • It needs to generate certificates and write the kubeconfig
# • Without waiting, kubectl provider tries to connect too early
# • This loops for up to 60 seconds checking for the fileCommon issues it prevents:
# • "kubeconfig not found" errors
# • "connection refused" errors
# • Race conditions in Terraform

resource "null_resource" "wait_for_kubeconfig" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      echo "Waiting for k3s API server to be ready..."
      export KUBECONFIG="${path.cwd}/output/kubeconfig.yaml"
      
      for i in $(seq 1 60); do
        if [ -f "${path.cwd}/output/kubeconfig.yaml" ]; then
          # File exists, now check if API is responding
          if kubectl get nodes &>/dev/null; then
            echo "k3s API server is ready!"
            exit 0
          fi
        fi
        echo "Attempt $i/60: Waiting for API server..."
        sleep 2
      done
      
      echo "Timeout waiting for k3s API server"
      exit 1
    EOT
  }

  depends_on = [docker_container.k3s_server]

  triggers = {
    server_id = docker_container.k3s_server[0].id
  }
}
