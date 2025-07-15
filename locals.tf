locals {

  tags = {
    environment = var.environment
    application = var.application
  }

  hub_rg_name   = "rg-hub-${var.application}-${var.location}"
  dev_rg_name   = "rg-dev-${var.application}-${var.location}"
  test_rg_name  = "rg-test-${var.application}-${var.location}"
  prod_rg_name  = "rg-prod-${var.application}-${var.location}"
  keyvault_name = "kv-hub-${var.application}-${var.location}"
  # vnet_name                 = "vnet-${var.environment}-${var.application}-${var.location}"
  # infra_snet_name       = "snet-infra-${var.environment}-${var.application}-${var.location}"
  # public_snet_name      = "snet-public-${var.environment}-${var.application}-${var.location}"
  # private_snet_name     = "snet-private-${var.environment}-${var.application}-${var.location}"
  # infra_nsg_name        = "nsg-infra-${var.environment}-${var.application}-${var.location}"
  # public_nsg_name       = "nsg-public-${var.environment}-${var.application}-${var.location}"
  # private_nsg_name      = "nsg-private${var.environment}-${var.application}-${var.location}"
  # landing_name              = "strblob${var.environment}${var.application}${var.location}"
  # lake_name                 = "stradls${var.environment}${var.application}${var.location}"
  # adf_name                  = "adf-${var.environment}-${var.application}-${var.location}"
  # databricks_workspace_name = "dbx-${var.environment}-${var.application}-${var.location}"
  # metastore_storage_name = "metastore${var.environment}${var.application}${var.location}"
  # access_connector_name = "ucac-${var.environment}-${var.application}-${var.location}"

  # allow-eg-in = {
  #   access = "Allow"
  #   priority = 9000
  #   protocol = "Tcp"
  #   source_port_range = "*"
  #   source_address_prefixes = ["172.13.35.0/32"]
  #   destination_port_range = ["443, 1443, 1433"]
  #   destination_address_prefix = "*"
  # }

  nsg_in_rules = {
    # allow-eg-in = local.allow-eg-in
  }
}
