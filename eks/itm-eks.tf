#####
# KMS
#####
resource "aws_kms_key" "eks" {
  description = var.cluster_name
}

resource "aws_kms_alias" "eks" {
  name          = format("alias/%s", var.cluster_name)
  target_key_id = aws_kms_key.eks.key_id
  depends_on = [
    aws_kms_key.eks
  ]
}

##########
# EKS ROLE
##########
data "aws_iam_policy_document" "eks_cluster_role" {

  version = "2012-10-17"
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "eks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name               = "itm-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_role.json
}

resource "aws_iam_role_policy_attachment" "eks-cluster-cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

#############
# EKS CLUSTER
#############
resource "aws_eks_cluster" "main" {

  name     = "itm-eks"
  version  = var.k8s_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    security_group_ids = [
      aws_security_group.cluster_sg.id,
      aws_security_group.cluster_nodes_sg.id
    ]
    subnet_ids = [
      local.itm_subnet_eks_2a,
      local.itm_subnet_eks_2c
    ]
  }
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = [
    "api", "audit", "authenticator", "controllerManager", "scheduler"
  ]

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}"     = "shared"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned",
    "k8s.io/cluster-autoscaler/enabled"             = true
  }

  depends_on = [
    aws_kms_key.eks,
    aws_iam_role_policy_attachment.eks-cluster-cluster,
    aws_iam_role_policy_attachment.eks-cluster-service
  ]

}

data "tls_certificate" "itm_tls" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.itm_tls.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.itm_tls.url
}
data "aws_iam_policy_document" "example_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "example" {
  assume_role_policy = data.aws_iam_policy_document.example_assume_role_policy.json
  name               = "example"
}

resource "aws_security_group" "cluster_sg" {
  name   = "itm-eks-cluster-sg"
  vpc_id = local.itm_vpc_id

  egress {
    from_port = 0
    to_port   = 0

    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "itm-eks-cluster-sg"
    created-by = "itm"
    service = "security-group"
    "karpenter.sh/discovery" = "itm-eks"
  }

}

resource "aws_security_group_rule" "cluster_ingress_https" {
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"

  security_group_id = aws_security_group.cluster_sg.id
  type              = "ingress"
  depends_on = [
    aws_security_group.cluster_sg
  ]
}

resource "aws_security_group_rule" "nodeport_cluster" {
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 30000
  to_port     = 32768
  description = "nodeport"
  protocol    = "tcp"

  security_group_id = aws_security_group.cluster_sg.id
  type              = "ingress"
  depends_on = [
    aws_security_group.cluster_sg
  ]
}

resource "aws_security_group_rule" "nodeport_cluster_udp" {
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 30000
  to_port     = 32768
  description = "nodeport"
  protocol    = "udp"

  security_group_id = aws_security_group.cluster_sg.id
  type              = "ingress"
  depends_on = [
    aws_security_group.cluster_sg
  ]
}

output "endpoint" {
  value = aws_eks_cluster.main.endpoint
}

############
# NODE ROLES
############

data "aws_iam_policy_document" "eks_nodes_role" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "eks_nodes_roles" {
  name               = format("%s-eks-nodes", var.cluster_name)
  assume_role_policy = data.aws_iam_policy_document.eks_nodes_role.json
}

resource "aws_iam_role_policy_attachment" "cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes_roles.name
}

resource "aws_iam_role_policy_attachment" "node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes_roles.name
}

resource "aws_iam_role_policy_attachment" "ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes_roles.name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_nodes_roles.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.eks_nodes_roles.name
}

data "aws_iam_policy_document" "csi_driver" {
  version = "2012-10-17"

  statement {

    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = [
      aws_kms_key.eks.arn
    ]

  }

}

resource "aws_iam_policy" "csi_driver" {
  name        = format("%s-csi-driver", var.cluster_name)
  path        = "/"
  description = var.cluster_name

  policy = data.aws_iam_policy_document.csi_driver.json
}

resource "aws_iam_policy_attachment" "csi_driver" {
  name = "aws_load_balancer_controller_policy"

  roles = [aws_iam_role.eks_nodes_roles.name]

  policy_arn = aws_iam_policy.csi_driver.arn
}

resource "aws_iam_instance_profile" "nodes" {
  name = "${var.cluster_name}-instance-profile"
  role = aws_iam_role.eks_nodes_roles.name
}

#############
# NODE GROUPS
#############

resource "aws_eks_node_group" "main" {

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = format("%s-node-group", aws_eks_cluster.main.name)
  node_role_arn   = aws_iam_role.eks_nodes_roles.arn

  subnet_ids = [
    local.itm_subnet_eks_2a,
    local.itm_subnet_eks_2c
  ]

  instance_types = var.nodes_instances_sizes

  scaling_config {
    desired_size = lookup(var.auto_scale_options, "desired")
    max_size     = lookup(var.auto_scale_options, "max")
    min_size     = lookup(var.auto_scale_options, "min")
  }

  labels = {
    "ingress/ready" = "true"
  }

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}"     = "owned",
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned",
    "k8s.io/cluster-autoscaler/enabled"             = true,
    "karpenter.sh/discovery" = aws_eks_cluster.main.name
  }

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }

  depends_on = [
    kubernetes_config_map.aws-auth
  ]

  timeouts {
    create = "60m"
    update = "2h"
    delete = "2h"
  }
}

resource "aws_security_group" "cluster_nodes_sg" {
  name   = "itm-eks-worker-sg"
  vpc_id = local.itm_vpc_id

  egress {
    from_port = 0
    to_port   = 0

    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "itm-eks-worker-sg"
    "karpenter.sh/discovery" = "itm-eks"
  }

}

resource "aws_security_group_rule" "nodeport" {
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 30000
  to_port     = 32768
  description = "nodeport"
  protocol    = "tcp"

  security_group_id = aws_security_group.cluster_nodes_sg.id
  type              = "ingress"
}


# resource "kubernetes_namespace" "sealed_secrets_ns" {
#   metadata {
#     name = "sealed-secrets"
#   }
#   labels = {
#       mylabel = "label-value"
#     }
#   depends_on = [
#     aws_eks_cluster.main,
#     aws_eks_node_group.main
#   ]
# }
