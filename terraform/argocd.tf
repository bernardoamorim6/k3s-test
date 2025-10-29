# Create argocd namespace
resource "kubectl_manifest" "argocd_namespace" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: argocd
  YAML

  # IMPORTANT: Wait for k3s cluster to be ready AND kubeconfig to exist!
  depends_on = [
    docker_container.k3s_server,
    docker_container.k3s_agent,
    null_resource.wait_for_kubeconfig # Add this line!
  ]
}


# Install Argo CD
resource "kubectl_manifest" "argocd_install" {
  yaml_body = file("${path.module}/argocd-install.yaml")

  depends_on = [kubectl_manifest.argocd_namespace]
}

# NodePort service
resource "kubectl_manifest" "argocd_server_nodeport" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Service
    metadata:
      name: argocd-server-nodeport
      namespace: argocd
    spec:
      type: NodePort
      selector:
        app.kubernetes.io/name: argocd-server
      ports:
        - port: 80
          targetPort: 8080
          nodePort: 30080
          protocol: TCP
  YAML

  depends_on = [kubectl_manifest.argocd_install]
}
