output "cluster_name" {
  description = "Name of the k3s cluster"
  value       = var.cluster_name
}

output "kubeconfig_path" {
  description = "Path to kubeconfig file"
  value       = "${path.cwd}/output/kubeconfig.yaml"
}

output "api_endpoint" {
  description = "Kubernetes API endpoint"
  value       = "https://127.0.0.1:${var.api_port}"
}

output "connection_command" {
  description = "Command to connect to the cluster"
  value       = "export KUBECONFIG=${path.cwd}/output/kubeconfig.yaml"
}

output "server_nodes" {
  description = "Server node names"
  value       = [for s in docker_container.k3s_server : s.name]
}

output "agent_nodes" {
  description = "Agent node names"
  value       = [for a in docker_container.k3s_agent : a.name]
}
