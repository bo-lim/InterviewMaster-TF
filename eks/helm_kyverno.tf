# resource "helm_release" "kyverno" {
#   name             = "kyverno"
#   chart            = "kyverno"
#   repository       = "https://kyverno.github.io/kyverno/"
#   namespace        = "kyverno"
#   create_namespace = true
#   version    = "v1.12.3"
#   depends_on = [
#     aws_eks_cluster.main,
#     aws_eks_node_group.main
#   ]
# }