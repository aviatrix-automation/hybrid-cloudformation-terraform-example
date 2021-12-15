terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
    }    
  }
  required_version = ">= 0.15"
}
