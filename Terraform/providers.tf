provider "aws" {
  region     = "eu-central-1"
}

provider "aviatrix" {
  controller_ip           = var.controller_ip
  username                = var.admin
  password                = var.password
}