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
  source      = "git::https://github.com/obytes/terraform-aws-argocd.git?ref=main"
  cluster_id  = module.eks.cluster_id
  oidc_issuer = module.eks.cluster_oidc_issuer_url
}