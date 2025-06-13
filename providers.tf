terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    argocd = {
      source = "argoproj-labs/argocd"
      version = "7.8.2"
  }
}
}