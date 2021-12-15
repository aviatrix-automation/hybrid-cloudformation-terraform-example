#Aviatrix Transit VPC + gateways
module "transit_aws_1" {
  source  = "terraform-aviatrix-modules/aws-transit/aviatrix"
  version = "v4.0.3"

  cidr    = "10.1.0.0/23"
  region  = "eu-central-1"
  account = "AWS"
}

#Query CloudFormation stack outputs
data "aws_cloudformation_stack" "spoke_vpc" {
  name = "SpokeVPC"
}

#Aviatrix Spoke gateways in VPC created by CloudFormation
module "spoke_aws_1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.0.0"

  cloud           = "AWS"
  name            = "App1"
  region          = "eu-central-1"
  account         = "AWS"
  transit_gw      = module.transit_aws_1.transit_gateway.gw_name

  #Use VPC created by CloudFormation:
  use_existing_vpc = true
  vpc_id           = data.aws_cloudformation_stack.spoke_vpc.outputs["VpcId"]
  gw_subnet        = data.aws_cloudformation_stack.spoke_vpc.outputs["GatewaySubnet"]
  hagw_subnet      = data.aws_cloudformation_stack.spoke_vpc.outputs["HaGatewaySubnet"]
}
