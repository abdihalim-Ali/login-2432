# Variables
variable aws_access_key {
  type        = string
  description = "Input AWS Access Key"
}

variable aws_secret_key {
  type        = string
  description = "Input AWS Secret Key"
}

# Variable VPC CIDR
variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

# Variable VPC Tenancy
variable "vpc_tenancy" {
  type = string
  default = "default"
}

# Variable VPC Name
variable "vpc_name" {
  type = string
  default = "login"
}

# Variable Public Subnets
variable "public_subnet_cidrs" {
  type = map(string)
  default = {
    frontend = "10.0.0.0/24"
    backend = "10.0.1.0/24" 
  }
}

# Variable Public IP
variable "sn_pub_ip" {
  type = string
  default = "true"
}

# Variable Private Subnets
variable "private_subnet_cidr" {
  type = string
  default = "10.0.2.0/24"
}

# Variable Public IP NO
variable "sn_pvt_ip" {
  type = string
  default = "false"
}

# Variable FE Ports
variable "web_ingress_ports" {
  description = "Ports Allowed"
  type        = list(object({
    port  = number
    cidr  = string
  }))
  default = [
    { port = 22, cidr = "0.0.0.0/0"},
    { port = 80, cidr = "0.0.0.0/0"}
  ]
}  

# Variable BE Ports
variable "app_ingress_ports" {
  description = "Ports Allowed"
  type        = list(object({
    port  = number
    cidr  = string
  }))
  default = [
    { port = 22, cidr = "0.0.0.0/0"},
    { port = 8080, cidr = "0.0.0.0/0"}
  ]
}  

# Variable DB Ports
variable "db_ingress_ports" {
  description = "Ports Allowed"
  type        = list(object({
    port  = number
    cidr  = string
  }))
  default = [
    { port = 22, cidr = "0.0.0.0/0"},
    { port = 5432, cidr = "0.0.0.0/0"}
  ]
}