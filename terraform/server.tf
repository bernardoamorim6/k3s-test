resource "docker_container" "k3s_server" {
  count = var.server_count

  name  = "${var.cluster_name}-server-${count.index}"
  image = docker_image.k3s.image_id

  privileged = true

  command = [
    "server",
    "--disable=traefik",
    "--tls-san=127.0.0.1",
    "--bind-address=0.0.0.0"
  ]

  env = [
    "K3S_TOKEN=my-super-secret-token",
    "K3S_KUBECONFIG_OUTPUT=/output/kubeconfig.yaml",
    "K3S_KUBECONFIG_MODE=666"
  ]

  ports {
    internal = 6443
    external = var.api_port + count.index
  }

  networks_advanced {
    name = docker_network.k3s_network.name
  }

  volumes {
    host_path      = "${path.cwd}/output"
    container_path = "/output"
  }

  volumes {
    container_path = "/var/lib/rancher/k3s"
  }
}
