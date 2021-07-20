resource "aws_internet_gateway" "igw" {
  vpc_id = var.igw_vpc_id
  tags = merge(var.common_tags, var.igw_additional_tags)
}
resource "aws_eip" "eip" {
  for_each = var.nat_gateways
  vpc = true
  tags = merge(var.common_tags, {Name = each.key}, var.eip_additional_tags)
}
resource "aws_nat_gateway" "nat_gateway" {
  for_each = var.nat_gateways
  allocation_id = aws_eip.eip[each.key].id
  subnet_id     = each.value["subnet_id"]
  tags = merge(var.common_tags, {Name = each.key}, var.nat_gw_additional_tags)
  depends_on = [aws_internet_gateway.igw, aws_eip.eip]
}
