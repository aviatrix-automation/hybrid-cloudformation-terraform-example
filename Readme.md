# hybrid-cloudformation-terraform-example

# Intro
Some organizations already use CloudFormation in order to deploy AWS resources. As such they may have standardized workflows and templates for infrastructure like VPC's, Subnets and other AWS native components.
Aviatrix only supports deployment of it's components via Terraform, which is cloud agnostic. These organizations might not be ready or willing to adopt Terraform for the deployment of all resources, both AWS and Aviatrix. This is especially true for VPC's where workloads reside. For deploying transit/firenet VPC's it is strongly advised to use the Aviatrix Terraform provider, as these VPC's are highly customized for their specific purpose.

This repository shows an example of how to use a hybrid of CloudFormation and Terraform to deploy a combination of AWS and Aviatrix infrastructure.

- The CloudFormation template will deploy a VPC with public and private subnets.
- The Terraform code will deploy a pair of Aviatrix spoke and transit gateways and attach them.

The mechanism used to feed te relevant information from CloudFormation to Terraform, is the CloudFormation stack outputs. As you can see below, the CloudFormation template has these outputs configured.
```
Outputs:
  VpcId:
    Description: Outputs the ID of the created VPC
    Value: !GetAtt SpokeVPC.VpcId
  GatewaySubnet:
    Description: Outputs the CIDR of the Aviatrix gateway subnet
    Value: !Select [0, !Cidr [ !Ref VpcCidr, 2, 6 ]]
  HaGatewaySubnet:
    Description: Outputs the CIDR of the Aviatrix HA gateway subnet
    Value: !Select [1, !Cidr [ !Ref VpcCidr, 2, 6 ]]
```

In Terraform this information gets pulled in through a data source, looking up these stack outputs:
```
data "aws_cloudformation_stack" "spoke_vpc" {
  name = "SpokeVPC"
}
```

These stack outputs can then be referenced as follows:
```
  vpc_id           = data.aws_cloudformation_stack.spoke_vpc.outputs["VpcId"]
  gw_subnet        = data.aws_cloudformation_stack.spoke_vpc.outputs["GatewaySubnet"]
  hagw_subnet      = data.aws_cloudformation_stack.spoke_vpc.outputs["HaGatewaySubnet"]
```  

## Pre-requisites
This documentation assumes AWS CLI and Terraform environments have been set up. And AWS CLI is authenticated.

## Deployment
1. Clone this repository and change directory to the repository on disk
```
git clone <yada>
cd <yada>
```
2. Create the CloudFormation stack based on the included template
```
cd CloudFormation
aws cloudformation --region eu-central-1 create-stack --stack-name SpokeVPC --template-body file://spoke_vpc.yaml
cd ..
```
3. Wait for and confirm complete deployment of the CloudFormation stack. Result should be "CREATE_COMPLETE".
```
aws cloudformation describe-stacks --stack-name SpokeVPC | grep StackStatus
```
4. Initialize plan and deploy the Terraform code
```
cd Terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
cd ..
```

## Destruction
1. Destroy the Terraform resources
```
cd Terraform
terraform destroy
cd ..
```
2. Delete the CloudFormation stack
```
cd CloudFormation
aws cloudformation delete-stack --stack-name SpokeVPC
cd ..
```