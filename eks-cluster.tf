
#************************* EKS-Cluster ****************************************#

resource "aws_eks_cluster" "cluster" {
  name = "cluster"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.cluster.arn
  version  = "1.34"

 
  vpc_config {
    subnet_ids = [
      aws_subnet.subnet_depi_public1.id,
      aws_subnet.subnet_depi_public2.id,
      aws_subnet.subnet_depi_public3.id,
    ]
    endpoint_public_access  = true
    security_group_ids = [aws_security_group.security_group1.id]  

  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_internet_gateway.gateway_depi,
  ]
  

}

#************* EKS-role-master *********************#

resource "aws_iam_role" "cluster" {
  name = "eks-cluster-access-resource"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"                              //to make eks communicate with cluster
  role       = aws_iam_role.cluster.name
}


#****************************** Role for ec2 where nodes be created ***********************************#

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_role.name
}


resource "aws_iam_role_policy_attachment" "node_AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver_role.name
}


#****************** aws_eks_addon ******************#

resource "aws_eks_addon" "vpc_cni" {
  cluster_name      = aws_eks_cluster.cluster.name
  addon_name        = "vpc-cni"
  addon_version     = "v1.20.4-eksbuild.1"

}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = aws_eks_cluster.cluster.name
  addon_name        = "kube-proxy"
  addon_version     = "v1.34.0-eksbuild.2"

}


resource "aws_eks_addon" "node_coredns_agent" {
  cluster_name      = aws_eks_cluster.cluster.name
  addon_name        = "coredns"
  addon_version     = "v1.12.3-eksbuild.1"
  
  depends_on = [
    aws_eks_node_group.node_group  # ← أضف السطر ده
  ]
}

resource "aws_eks_addon" "metrics_server" {
  cluster_name      = aws_eks_cluster.cluster.name
  addon_name        = "metrics-server"
  addon_version     = "v0.8.0-eksbuild.3"
  
  depends_on = [
    aws_eks_node_group.node_group  # ← أضف السطر ده
  ]
}
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.cluster.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.53.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEBSCSIDriverPolicy
  ]
}

resource "aws_eks_addon" "node_monitoring_agent" {
  cluster_name      = aws_eks_cluster.cluster.name
  addon_name        = "aws-node-termination-handler"
  addon_version     = "v1.4.2-eksbuild.1"
}

resource "aws_eks_addon" "eks-pod-identity-agent" {
  cluster_name      = aws_eks_cluster.cluster.name
  addon_name        = "eks-pod-identity-agent"
  addon_version     = "v1.3.9-eksbuild.5"
}
