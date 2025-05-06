# Create EKS Cluster
resource "aws_eks_cluster" "example" {
  name     = "${var.project}-${var.env}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  version = "1.32"
  tags = {
    Environment = "${var.env}"
    Project     = "${var.project}"
  }
}


# Create managed node group
resource "aws_eks_node_group" "example_nodes" {
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = "${var.project}-${var.env}-eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_node_AmazonEKS_CNI_Policy,
  ]
  tags = {
    Environment = "${var.env}"
    Project     = "${var.project}"
  }
}
