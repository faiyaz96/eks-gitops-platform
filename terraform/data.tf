data "aws_autoscaling_group" "eks_nodes" {
  tags = {
    "eks:nodegroup-name" = aws_eks_node_group.example_nodes.node_group_name
    "eks:cluster-name"   = aws_eks_cluster.example.name
  }
}
