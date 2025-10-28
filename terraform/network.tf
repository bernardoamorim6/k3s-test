resource "docker_network" "k3s_network" {
  name   = "${var.cluster_name}-network"
  driver = "bridge"

  ipam_config {
    subnet  = "172.20.0.0/16"
    gateway = "172.20.0.1"
  }
}
