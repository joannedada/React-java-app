provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    }
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.15.3" # Pin to specific version
  cluster_name    = "gitops-cluster"
  cluster_version = "1.27"
  subnet_ids      = ["subnet-0d278c7a9fd1656ac", "subnet-0f663e00577162d72"]
  vpc_id          = "vpc-07d95f7f3f036f70b"

  # Enable IAM OIDC provider for IRSA
  enable_irsa = true

  node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "t3.medium"
    }
  }
}


module "argocd" {
  source  = "cloudposse/argocd/aws"
  version = "0.5.0"
  
  # Required parameters
  cluster_name          = module.eks.cluster_id
  cluster_endpoint      = module.eks.cluster_endpoint
  cluster_certificate   = module.eks.cluster_certificate_authority_data
  oidc_provider_arn     = module.eks.oidc_provider_arn
  
  # Recommended settings
  namespace             = "argocd"
  chart_version         = "5.46.8" # ArgoCD chart version
  wait                  = true
  create_namespace      = true
  repository            = "https://argoproj.github.io/argo-helm"
  
  # Networking
  ingress_enabled       = false # Set to true if you need ingress
  service_type          = "LoadBalancer"
  
  # Security
  rbac_enabled          = true
  create_iam_resources  = true
}