variable "common_tags" {
  type = map
}
variable "igw_additional_tags" {
  type = map
  default = {}
}
variable "igw_vpc_id" {
  type    = string
}
variable "eip_additional_tags" {
  type = map
  default = {}
}
variable "nat_gw_additional_tags" {
  type = map
  default = {}
}
variable "nat_gateways" {
  type = map(map(string))
  default = {}
}
