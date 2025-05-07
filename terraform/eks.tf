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


resource "aws_autoscaling_group" "eks_node_group" {
  name                      = "eks-eks-gitops-platform-dev-eks-node-group-a2cb53cd-51dd-1585-b4ae-b45fbcd11b4b"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  default_cooldown          = 300
  health_check_type         = "EC2"
  health_check_grace_period = 15
  vpc_zone_identifier = [
    "subnet-0ad647da1f8b149a6",
    "subnet-0bf9b6c6f235634be",
    "subnet-064f128a373a921b5"
  ]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = "lt-0d8a7420798154cb5"
        version            = "1"
      }

      override {
        instance_type = "t3.medium"
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 100
      on_demand_allocation_strategy            = "prioritized"
      spot_allocation_strategy                 = "lowest-price"
      spot_instance_pools                      = 2
    }
  }

  # Tags to match the original state
  tag {
    key                 = "eks:cluster-name"
    value               = "eks-gitops-platform-dev-eks-cluster"
    propagate_at_launch = true
  }

  tag {
    key                 = "eks:nodegroup-name"
    value               = "eks-gitops-platform-dev-eks-node-group"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/eks-gitops-platform-dev-eks-cluster"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/eks-gitops-platform-dev-eks-cluster"
    value               = "owned"
    propagate_at_launch = true
  }

  # Restoring enabled metrics
  enabled_metrics = [
    "GroupAndWarmPoolDesiredCapacity",
    "GroupAndWarmPoolTotalCapacity",
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingCapacity",
    "GroupPendingInstances",
    "GroupStandbyCapacity",
    "GroupStandbyInstances",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances",
    "WarmPoolDesiredCapacity",
    "WarmPoolMinSize",
    "WarmPoolPendingCapacity",
    "WarmPoolTerminatingCapacity",
    "WarmPoolTotalCapacity",
    "WarmPoolWarmedCapacity"
  ]

  # Additional configuration for drift corrections
  force_delete                     = false
  force_delete_warm_pool           = false
  ignore_failed_scaling_activities = false
  wait_for_capacity_timeout        = "10m"

  termination_policies = [
    "AllocationStrategy",
    "OldestLaunchTemplate",
    "OldestInstance"
  ]

  # Tag for Name
  tag {
    key                 = "Name"
    value               = "eks-node"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}





resource "aws_autoscaling_schedule" "scale_down" {
  scheduled_action_name  = "${var.project}-${var.env}-scale-down"
  autoscaling_group_name = aws_autoscaling_group.eks_node_group.name
  desired_capacity       = 0
  min_size               = 0
  max_size               = 0
  recurrence             = "0 0 * * *" # Midnight UTC
}

resource "aws_autoscaling_schedule" "scale_up" {
  scheduled_action_name  = "${var.project}-${var.env}-scale-up"
  autoscaling_group_name = aws_autoscaling_group.eks_node_group.name
  desired_capacity       = 2
  min_size               = 1
  max_size               = 3
  recurrence             = "0 12 * * *" # Noon UTC
}
