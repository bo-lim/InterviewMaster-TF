resource "kubernetes_namespace" "sealed_secrets_ns" {
  metadata {
    name = "sealed-secrets"
  }
  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main
  ]
}
resource "helm_release" "sealed_secrets" {
  name             = "sealed-secrets"
  chart            = "sealed-secrets"
  repository       = "https://bitnami-labs.github.io/sealed-secrets"
  namespace        = "sealed-secrets"
  # create_namespace = true
  
  set {
    name  = "fullnameOverride"
    value = "sealed-secrets-controller"
  }
  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    kubernetes_namespace.sealed_secrets_ns
  ]
}