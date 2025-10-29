# What agents do:
#   • Run workloads (your actual applications)
#   • Report status back to the server
#   • Execute commands from the control plane

resource "docker_container" "k3s_agent" {
  count = var.agent_count

  name  = "${var.cluster_name}-agent-${count.index}"
  image = docker_image.k3s.image_id

  privileged = true

  command = [
    "agent"
  ]

  env = [
    # K3S_URL : Address of the server (using Docker network DNS)
    "K3S_URL=https://${docker_container.k3s_server[0].name}:6443",
    # K3S_TOKEN : Must match the server's token
    "K3S_TOKEN=my-super-secret-token"
  ]

  networks_advanced {
    name = docker_network.k3s_network.name
  }

  volumes {
    container_path = "/var/lib/rancher/k3s"
  }
  # Ensures server exists before agents try to join
  depends_on = [docker_container.k3s_server]
}
