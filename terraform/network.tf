# What it does:
# • Creates an isolated network for cluster communication
# • All k3s containers can talk to each other via this network
# • Uses subnet 172.20.0.0/16 (65,536 available IP addresses)
# Why we need it:
# • The server and agents need to communicate
# • Isolates cluster traffic from other Docker containers
# • Provides DNS resolution between containers (containers can find each other by name)

resource "docker_network" "k3s_network" {
  name   = "${var.cluster_name}-network"
  driver = "bridge"

  ipam_config {
    subnet  = "172.20.0.0/16"
    gateway = "172.20.0.1"
  }
}
