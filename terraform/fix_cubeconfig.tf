resource "null_resource" "fix_kubeconfig" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      # Wait for kubeconfig to exist
      while [ ! -f "${path.cwd}/output/kubeconfig.yaml" ]; do
        echo "Waiting for kubeconfig..."
        sleep 2
      done
      
      # Fix the server address
      sed -i 's|https://0.0.0.0:6443|https://127.0.0.1:6443|g' "${path.cwd}/output/kubeconfig.yaml"
      echo "Kubeconfig fixed: server address updated to 127.0.0.1"
    EOT
  }

  depends_on = [docker_container.k3s_server]

  triggers = {
    server_id = docker_container.k3s_server[0].id
  }
}
