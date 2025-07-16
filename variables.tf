variable "databricks_account_id" {
  type        = string
  description = "The ID of the entire databricks account. Find in Account Console"
}

variable "environment" {
  type        = string
  description = "dev, test, prod"
}

variable "application" {
  type        = string
  description = "The project"
}

variable "location" {
  type        = string
  description = "The location"
}

variable "location_short" {
  type        = string
  description = "The location in short form, e.g. weu for westeurope"
}


variable "hub_vnet_cidr" {
  type        = string
  description = "VNet CIDR range"
}

variable "dev_vnet_cidr" {
  type        = string
  description = "VNet CIDR range"
}

variable "prod_vnet_cidr" {
  type        = string
  description = "VNet CIDR range"
}

variable "build_agent_subnet_cidr" {
  type        = string
  description = "Subnet CIDR range"
}

variable "gateway_subnet_cidr" {
  type        = string
  description = "Subnet CIDR range"
}
