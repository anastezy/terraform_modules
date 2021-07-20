variable "vpc_network_cidr" {
  type    = string
}
variable "vpc_enable_dns_hostnames" {
  type    = bool
  default = false
}
variable "common_tags" {
  type = map
}
variable "vpc_additional_tags" {
  type = map
}
variable "main_route_table" {
  type    = string
}
variable "subnets" {
  type = map(object({
              az              = string
              cidr            = string
              additional_tags = map(string)
              route_table     = string
  }))
  default = {}
  }

variable "route_tables" {
  type = map(map(map(string)))
  default = {}
}
variable "access_lists" {
  type = map(object({
             subnets = list(string)
             ingress = map(map(string))
             egress  = map(map(string))
    }))
  default = {}
}
variable "associated_domains" {
  type = list(string)
  default = []
}
