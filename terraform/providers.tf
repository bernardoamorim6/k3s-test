# What is a Terraform provider?
# • A plugin that knows how to interact with an API
# • Docker provider → talks to Docker API

provider "docker" {
  host = "unix:///var/run/docker.sock"
}


