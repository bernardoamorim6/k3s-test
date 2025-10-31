resource "docker_volume" "k3s_server_data" {
  count = var.server_count
  name  = "${var.cluster_name}-server-${count.index}-data"
}

resource "docker_container" "k3s_server" {
  count = var.server_count

  name  = "${var.cluster_name}-server-${count.index}"
  image = docker_image.k3s.image_id

  # • Gives the container full access to the host's devices
  # • Required because k3s needs to:
  # • Create network interfaces
  # • Mount filesystems
  # • Manage other containers (pods)
  # • Think of it like "admin mode" for the container
  privileged = true




  # • Runs k3s in "server" mode (control plane)
  command = [
    "server",
    # • --disable=traefik : Disables the default ingress controller (we don't need it yet)
    "--disable=traefik",
    # • --tls-san=127.0.0.1 : Adds localhost to the TLS certificate (so we can connect from our machine)
    "--tls-san=127.0.0.1",
    "--tls-san=172.20.0.10",
    # • --bind-address=0.0.0.0 : Listen on all interfaces
    "--bind-address=0.0.0.0"
  ]

  env = [
    # Shared secret that agents use to join the cluster (like a password)
    "K3S_TOKEN=my-super-secret-token",
    #  Where to write the kubeconfig file
    "K3S_KUBECONFIG_OUTPUT=/output/kubeconfig.yaml",
    # • K3S_KUBECONFIG_MODE=666 : 
    "K3S_KUBECONFIG_MODE=666"
  ]

  ports {
    # 6443 is the Kubernetes API port
    # We map it to our host so we can run kubectl commands
    # This is how your kubectl talks to the cluster
    internal = 6443
    external = var.api_port + count.index
  }

  networks_advanced {
    name         = docker_network.k3s_network.name
    ipv4_address = "172.20.0.10"
  }


  # • Maps ./output on your machine to /output in the container
  # • This is how the kubeconfig file gets to your machine
  # • The container writes to /output/kubeconfig.yaml
  # • You read it from ./output/kubeconfig.yaml
  volumes {
    host_path      = "${path.cwd}/output"
    container_path = "/output"
  }

  # CHANGED: Named volume instead of anonymous
  volumes {
    volume_name    = docker_volume.k3s_server_data[count.index].name
    container_path = "/var/lib/rancher/k3s"
  }

  volumes {
    host_path      = "${path.cwd}/registries.yaml"
    container_path = "/etc/rancher/k3s/registries.yaml"
    read_only      = true
  }
}
