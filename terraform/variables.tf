variable "cluster_name" {
  description = "Name of the k3s cluster"
  type        = string
  default     = "my-k3s-cluster"
}

variable "k3s_version" {
  description = "k3s version to use"
  type        = string
  default     = "v1.28.5-k3s1"
}

variable "server_count" {
  description = "Number of server nodes (control plane)"
  type        = number
  default     = 1
}

variable "agent_count" {
  description = "Number of agent nodes (workers)"
  type        = number
  default     = 2
}

variable "api_port" {
  description = "Port to expose Kubernetes API"
  type        = number
  default     = 6443
}
