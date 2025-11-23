# ================== Output: Volume Details ==================

output "jenkins_volume_info" {
  value = {
    id                = aws_ebs_volume.esi_Volume.id
    availability_zone = aws_ebs_volume.esi_Volume.availability_zone
  }
  description = "Complete Jenkins EBS volume information"
}
output "eks_cluster_info" {
  value = {
    name = aws_eks_cluster.cluster.name
    arn  = aws_eks_cluster.cluster.arn
  }
  description = "EKS cluster details"
}
