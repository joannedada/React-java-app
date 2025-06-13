provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "gitops-cluster"
  cluster_version = "1.27"
  subnet_ids         = ["subnet-0d278c7a9fd1656ac", "subnet-0f663e00577162d72"] 
  vpc_id          = "vpc-07d95f7f3f036f70b" 

  node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_type = "t3.medium"
    }
  }
}

module "argocd" {
  source  = "cloudposse/argocd/aws"
  version = "0.5.0"  # Check for latest version
  
  cluster_name          = module.eks.cluster_id
  cluster_endpoint      = module.eks.cluster_endpoint
  cluster_certificate   = module.eks.cluster_certificate_authority_data
  oidc_provider_arn     = module.eks.oidc_provider_arn
}