# Local Docker Registry
# This acts like a mini Docker Hub running locally
# Your k3s cluster and Argo Workflows will push/pull images from here

resource "docker_volume" "registry_data" {
  name = "local-registry-data"
}

resource "docker_image" "registry" {
  name         = "registry:2"
  keep_locally = false
}

resource "docker_container" "registry" {
  name  = "local-registry"
  image = docker_image.registry.image_id

  ports {
    internal = 5000
    external = 5000 # Accessible at localhost:5000
  }

  # Connect to same network as k3s
  networks_advanced {
    name = docker_network.k3s_network.name
  }

  restart = "unless-stopped"

  # Store registry data persistently
  volumes {
    volume_name    = docker_volume.registry_data.name
    container_path = "/var/lib/registry"
  }
}


