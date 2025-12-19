# ****************************** EKS Node Group ***********************************#

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "node-group"
  node_role_arn   = aws_iam_role.node_role.arn
  ami_type        = "AL2023_x86_64_STANDARD"
  instance_types  = ["m7i-flex.large"]
  capacity_type   = "ON_DEMAND"
  disk_size       = 20

  subnet_ids = [
    aws_subnet.subnet_depi_private1.id,
    aws_subnet.subnet_depi_private2.id,
  ]

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly
  ]

  lifecycle {
    create_before_destroy = false
  }
}
