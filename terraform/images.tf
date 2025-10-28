resource "docker_image" "k3s" {
  name         = "rancher/k3s:${var.k3s_version}"
  keep_locally = false
}
