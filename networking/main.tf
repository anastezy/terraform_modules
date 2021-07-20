
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_network_cidr
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  tags = merge(var.common_tags, var.vpc_additional_tags)
}

resource "aws_subnet" "subnet" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.vpc.id
  availability_zone = lookup(each.value, "az")
  cidr_block        = lookup(each.value, "cidr")
  tags = merge(var.common_tags, {Name = each.key}, lookup(each.value, "additional_tags"))
}

resource "aws_route_table" "route_table" {
  for_each = var.route_tables
  vpc_id = aws_vpc.vpc.id
  dynamic "route" {
    for_each = each.value
    content {
      cidr_block = route.key
      carrier_gateway_id         = lookup(route.value, "carrier_gateway_id", "")
      egress_only_gateway_id     = lookup(route.value, "egress_only_gateway_id", "")
      gateway_id                 = lookup(route.value, "gateway_id", "")
      instance_id                = lookup(route.value, "instance_id", "")
      local_gateway_id           = lookup(route.value, "local_gateway_id", "")
      destination_prefix_list_id = lookup(route.value, "destination_prefix_list_id", null)
      ipv6_cidr_block            = lookup(route.value, "ipv6_cidr_block", null)
      nat_gateway_id             = lookup(route.value, "nat_gateway_id", "")
      network_interface_id       = lookup(route.value, "network_interface_id", "")
      transit_gateway_id         = lookup(route.value, "transit_gateway_id", "")
      vpc_endpoint_id            = lookup(route.value, "vpc_endpoint_id", "")
      vpc_peering_connection_id  = lookup(route.value, "vpc_peering_connection_id", "")
    }
  }
  tags = merge(var.common_tags, {Name = each.key})
}
data "aws_subnet" "subnets_id" {
  for_each   = var.subnets
  id         = aws_subnet.subnet[each.key].id
  depends_on = [aws_subnet.subnet]
}
data "aws_route_table" "route_table" {
  for_each       = var.route_tables
  route_table_id = aws_route_table.route_table[each.key].id
  depends_on     = [aws_route_table.route_table]
}

resource "aws_main_route_table_association" "main_rt_associations" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.route_table["${var.main_route_table}"].id
}

resource "aws_route_table_association" "rt_associations" {
  for_each       = var.subnets
  subnet_id      = data.aws_subnet.subnets_id[each.key].id
  route_table_id = data.aws_route_table.route_table[lookup(each.value, "route_table")].route_table_id
}

resource "aws_network_acl" "acl" {
  for_each = var.access_lists
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [for s in each.value.subnets : data.aws_subnet.subnets_id[s].id]

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      rule_no    = tonumber(ingress.key)
      protocol   = lookup(ingress.value, "protocol", "tcp")
      action     = lookup(ingress.value, "action", "allow")
      cidr_block = lookup(ingress.value, "cidr_block", "")
      from_port  = tonumber(lookup(ingress.value, "from_port", ""))
      to_port    = tonumber(lookup(ingress.value, "to_port", ""))
      icmp_code  = lookup(ingress.value, "icmp_code", null)
      icmp_type  = lookup(ingress.value, "icmp_type", null)
   }
  }
  dynamic "egress" {
    for_each = each.value.egress
    content {
      rule_no    = tonumber(egress.key)
      protocol   = lookup(egress.value, "protocol", "tcp")
      action     = lookup(egress.value, "action", "allow")
      cidr_block = lookup(egress.value, "cidr_block", "")
      from_port  = tonumber(lookup(egress.value, "from_port", ""))
      to_port    = tonumber(lookup(egress.value, "to_port", ""))
      icmp_code  = lookup(egress.value, "icmp_code", null)
      icmp_type  = lookup(egress.value, "icmp_type", null)
   }
}
  tags = merge(var.common_tags, {Name = each.key})
}

data "aws_route53_resolver_rule" "domain" {
  for_each = toset(var.associated_domains)
    domain_name = each.value
}
resource "aws_route53_resolver_rule_association" "domain_association" {
  for_each = toset(var.associated_domains)
    resolver_rule_id = data.aws_route53_resolver_rule.domain[each.value].id
    vpc_id           = aws_vpc.vpc.id
 }
