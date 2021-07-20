output "igw_id" {
  value = aws_internet_gateway.igw.id
}
output "igw_arn" {
  value = aws_internet_gateway.igw.arn
}
output "nat_gw_ids" {
   value = {for ngw in aws_nat_gateway.nat_gateway : ngw.tags_all["Name"] => ngw.id}
   description = "Subnets IDs. To get id for one of subnet use next string module.MODULE_NAME.nat_gw_ids[NAME_OF_NAT_GW]"
   depends_on = [aws_nat_gateway.nat_gateway]
 }
