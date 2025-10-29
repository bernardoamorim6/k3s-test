provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "kubectl" {
  config_path      = "${path.cwd}/output/kubeconfig.yaml"
  load_config_file = true
  insecure         = true # Skip certificate verification (safe for local dev)
}
