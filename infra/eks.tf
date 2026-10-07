module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id     = data.aws_vpc.existing.id
  subnet_ids = data.aws_subnets.existing.ids

  cluster_endpoint_public_access = true

  # Grants the identity running terraform cluster-admin via an access entry.
  enable_cluster_creator_admin_permissions = true

  # EKS Auto Mode: AWS manages nodes, scaling, and the core addons
  # (CoreDNS, kube-proxy, VPC CNI, EBS CSI, load balancer controller).
  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose", "system"]
  }
}
