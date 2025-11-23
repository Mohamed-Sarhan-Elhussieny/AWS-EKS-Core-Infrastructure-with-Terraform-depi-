

#****************************** EKS-node-group ***********************************#

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "node-group"
  node_role_arn   = aws_iam_role.node_role.arn
  ami_type = "AL2023_x86_64_STANDARD"
  instance_types = ["m7i-flex.large"]
  capacity_type ="ON_DEMAND"
  disk_size =20
  # source_security_group_ids = 
  subnet_ids = [
  aws_subnet.subnet_depi_public1.id,
  aws_subnet.subnet_depi_public2.id,
  aws_subnet.subnet_depi_public3.id,
  ]

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
depends_on = [
  aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
  aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
  aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  aws_iam_role_policy_attachment.node_AmazonEBSCSIDriverPolicy

]

}



#****************** EKS-node-role ******************#

resource "aws_iam_role" "node_role" {
  name = "node_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

