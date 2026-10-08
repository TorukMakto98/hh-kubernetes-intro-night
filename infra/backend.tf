# Backend blocks cannot use variables. The state bucket was created manually.
terraform {
  backend "s3" {
    bucket = "k8s-workshop-state-bucket"
    key    = "eks/terraform.tfstate"
    region = "eu-central-1"
  }
}
