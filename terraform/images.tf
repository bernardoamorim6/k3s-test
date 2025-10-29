# What it does:
# • Pulls the official k3s Docker image from Docker Hub
# • Version v1.28.5-k3s1 (Kubernetes 1.28.5)
# • keep_locally = false means it will be deleted on terraform destroy
# What's in the image:
# • Complete k3s binary
# • All Kubernetes components (API server, scheduler, controller, kubelet)
# • Networking components (CNI)
# • Storage drivers

resource "docker_image" "k3s" {
  name         = "rancher/k3s:${var.k3s_version}"
  keep_locally = false
}
