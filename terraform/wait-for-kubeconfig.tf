resource "null_resource" "wait_for_kubeconfig" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"] # Use bash instead of sh
    command     = <<-EOT
      echo "Waiting for kubeconfig to be generated..."
      for i in $(seq 1 30); do
        if [ -f "${path.cwd}/output/kubeconfig.yaml" ]; then
          echo "Kubeconfig found!"
          exit 0
        fi
        echo "Attempt $i/30: Still waiting..."
        sleep 2
      done
      echo "Timeout waiting for kubeconfig"
      exit 1
    EOT
  }

  depends_on = [docker_container.k3s_server]
}
