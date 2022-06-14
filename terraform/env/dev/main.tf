# Get configuration.
module "az_config" {
  source                          = "../../mod/az_config"
  application_code                = var.application_code
  billing_code                    = var.billing_code
  environment                     = var.environment
  point_of_contact                = var.point_of_contact
  unique_id                       = var.unique_id
  location_primary                = var.location_primary
  location_secondary              = var.location_secondary
}

# Create resource group.
resource "azurerm_resource_group" "rg" {
  location                        = var.location_primary
  name                            = "${module.az_config.item_name.resource_group}"
  tags                            = "${module.az_config.tags}"
}

# Create azure sql db - primary.
module "az_mssql_primary" {
  source                          = "../../mod/az_mssql_primary"                            /* The path to the module */
  location                        = var.location_primary                                    /* SQL primary location */
  resource_group_name             = azurerm_resource_group.rg.name                          /* The resource group */
  sql_primary_name                = "${module.az_config.item_name.sql_server_primary}"      /* SQL primary name */
  sql_db_name                     = var.sql_db_name                                         /* SQL db name */
}

# Create app service - primary.
module "az_appservice_primary" {
  source                          = "../../mod/az_appservice"                               /* The path to the module */
  depends_on                      = [module.az_mssql_primary]
  location                        = var.location_primary                                    /* The location */
  resource_group_name             = azurerm_resource_group.rg.name                          /* The resource group */
  log_analytics_workspace_name    = "${module.az_config.item_name.law_primary}"             /* The log analytics workspace name; must be globally unique across azure */
  appi_name                       = "${module.az_config.item_name.appi_primary}"            /* The application insights name */
  plan_name                       = "${module.az_config.item_name.asp_primary}"             /* The plan name */
  webapp_name                     = "${module.az_config.item_name.ase_primary}"             /* The webapp name */
  acr_login_server                = "https://acrdlnteudemoapps210713.azurecr.io"            /* The acr server */
  acr_admin_username              = "acrdlnteudemoapps210713"                               /* The acr username */
  connection_string               = module.az_mssql_primary.connection_string_primary       /* MODULE IMPORT - db connection string */
  autoscale_name                  = "autoscale-${var.location_primary}"                     /* The autoscale setting name */
}
