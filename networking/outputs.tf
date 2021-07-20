output "vpc_id" {
   value = aws_vpc.vpc.id
   description = "VPC ID"
 }
output "subnet_ids" {
   value = {for s in aws_subnet.subnet : s.tags_all["Name"] => s.id}
   description = "Subnets IDs. To get id for one of subnet use next string module.MODULE_NAME.subnet_ids[NAME_OF_SUBNET]"
 }
 output "subnet_ipv4" {
    value = {for s in aws_subnet.subnet : s.tags_all["Name"] => s.cidr_block}
    description = "Subnets IDs. To get id for one of subnet use next string module.MODULE_NAME.subnet_ids[NAME_OF_SUBNET]"
  }
