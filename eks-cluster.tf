# ************************* EKS Cluster ****************************************#

resource "aws_eks_cluster" "cluster" {
  name     = "cluster"
  role_arn = aws_iam_role.cluster.arn
  version  = "1.33"

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids = [
      aws_subnet.subnet_depi_public1.id,
      aws_subnet.subnet_depi_public2.id,
      aws_subnet.subnet_depi_public3.id,
    ]
    endpoint_public_access = true
    security_group_ids     = [aws_security_group.security_group1.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_internet_gateway.gateway_depi,
  ]

  lifecycle {
    ignore_changes = []
  }
}

# ****************** EKS Add-ons ******************#

resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.cluster.name
  addon_name    = "vpc-cni"
  addon_version = "v1.20.4-eksbuild.1"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.cluster.name
  addon_name    = "kube-proxy"
  addon_version = "v1.33.5-eksbuild.2"
}

resource "aws_eks_addon" "node_coredns_agent" {
  cluster_name  = aws_eks_cluster.cluster.name
  addon_name    = "coredns"
  addon_version = "v1.12.3-eksbuild.1"

  depends_on = [
    aws_eks_node_group.node_group
  ]
}

resource "aws_eks_addon" "metrics_server" {
  cluster_name  = aws_eks_cluster.cluster.name
  addon_name    = "metrics-server"
  addon_version = "v0.8.0-eksbuild.3"

  depends_on = [
    aws_eks_node_group.node_group
  ]
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.cluster.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.53.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEBSCSIDriverPolicy,
    aws_iam_role.ebs_csi_driver_role,
    aws_eks_node_group.node_group
  ]
}

resource "aws_eks_addon" "eks-pod-identity-agent" {
  cluster_name  = aws_eks_cluster.cluster.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.3.9-eksbuild.5"
}
