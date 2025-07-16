locals {

  tags = {
    environment = var.environment
    application = var.application
  }

  hub_rg_name   = "rg-hub-${var.application}-${var.location_short}"
  dev_rg_name   = "rg-dev-${var.application}-${var.location_short}"
  test_rg_name  = "rg-test-${var.application}-${var.location_short}"
  prod_rg_name  = "rg-prod-${var.application}-${var.location_short}"
  keyvault_name = "kv-hub-${var.application}-${var.location_short}"
  # vnet_name                 = "vnet-${var.environment}-${var.application}-${var.location_short}"
  infra_snet_dev           = "snet-infra-dev-${var.application}-${var.location_short}"
  public_snet_dev          = "snet-public-dev-${var.application}-${var.location_short}"
  private_snet_dev         = "snet-private-dev-${var.application}-${var.location_short}"
  public_nsg_dev           = "nsg-public-dev-${var.application}-${var.location_short}"
  private_nsg_dev          = "nsg-private-dev-${var.application}-${var.location_short}"
  adls_name_dev            = "stradlsdev${var.application}${var.location_short}"
  databricks_workspace_dev = "dbx-dev-${var.application}-${var.location_short}"
  ucac_dev                 = "ucac-dev-${var.application}-${var.location_short}"

  infra_snet_prod           = "snet-infra-prod-${var.application}-${var.location_short}"
  public_snet_prod          = "snet-public-prod-${var.application}-${var.location_short}"
  private_snet_prod         = "snet-private-prod-${var.application}-${var.location_short}"
  public_nsg_prod           = "nsg-public-prod-${var.application}-${var.location_short}"
  private_nsg_prod          = "nsg-private-prod-${var.application}-${var.location_short}"
  adls_name_prod            = "stradlsprod${var.application}${var.location_short}"
  databricks_workspace_prod = "dbx-prod-${var.application}-${var.location_short}"
  ucac_prod                 = "ucac-prod-${var.application}-${var.location_short}"


  # infra_nsg_dev        = "nsg-infra-dev-${var.application}-${var.location_short}"
  # lake_name                 = "stradls${var.environment}${var.application}${var.location_short}"
  # adf_name                  = "adf-${var.environment}-${var.application}-${var.location_short}"\
  # landing_name              = "strblob${var.environment}${var.application}${var.location_short}"

  # metastore_storage_name = "metastore${var.environment}${var.application}${var.location_short}"
  # access_connector_name = "ucac-${var.environment}-${var.application}-${var.location_short}"

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
