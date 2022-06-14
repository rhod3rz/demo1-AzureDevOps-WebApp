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

# Create azure sql db - secondary.
module "az_mssql_secondary" {
  source                          = "../../mod/az_mssql_secondary"                          /* The path to the module */
  depends_on                      = [module.az_mssql_primary]                               /* Wait for dependencies */
  location                        = var.location_secondary                                  /* SQL primary location */
  resource_group_name             = azurerm_resource_group.rg.name                          /* The resource group */
  sql_secondary_name              = "${module.az_config.item_name.sql_server_secondary}"    /* SQL secondary name */
  failover_group_name             = var.unique_id                                           /* The name of the failover group */
  sql_primary_id                  = module.az_mssql_primary.sql_primary_id                  /* SQL primary id - required for failover config */
  sql_database_db_id              = module.az_mssql_primary.sql_database_db_id              /* Database id - required for failover config */
}

# Create app service - primary.
module "az_appservice_primary" {
  source                          = "../../mod/az_appservice"                               /* The path to the module */
  depends_on                      = [module.az_mssql_primary,
                                     module.az_mssql_secondary]
  location                        = var.location_primary                                    /* The location */
  resource_group_name             = azurerm_resource_group.rg.name                          /* The resource group */
  log_analytics_workspace_name    = "${module.az_config.item_name.law_primary}"             /* The log analytics workspace name; must be globally unique across azure */
  plan_name                       = "${module.az_config.item_name.asp_primary}"             /* The plan name */
  webapp_name                     = "${module.az_config.item_name.ase_primary}"             /* The webapp name */
  acr_login_server                = "https://acrdlnteudemoapps210713.azurecr.io"            /* The acr server */
  acr_admin_username              = "acrdlnteudemoapps210713"                               /* The acr username */
  connection_string               = module.az_mssql_secondary.connection_string_failover    /* MODULE IMPORT - db connection string */
  autoscale_name                  = "autoscale-${var.location_primary}"                     /* The autoscale setting name */
}

# Create app service - secondary.
module "az_appservice_secondary" {
  source                          = "../../mod/az_appservice"                               /* The path to the module */
  depends_on                      = [module.az_mssql_primary,
                                     module.az_mssql_secondary]
  location                        = var.location_secondary                                  /* The location */
  resource_group_name             = azurerm_resource_group.rg.name                          /* The resource group */
  log_analytics_workspace_name    = "${module.az_config.item_name.law_secondary}"           /* The log analytics workspace name; must be globally unique across azure */
  plan_name                       = "${module.az_config.item_name.asp_secondary}"           /* The plan name */
  webapp_name                     = "${module.az_config.item_name.ase_secondary}"           /* The webapp name */
  acr_login_server                = "https://acrdlnteudemoapps210713.azurecr.io"            /* The acr server */
  acr_admin_username              = "acrdlnteudemoapps210713"                               /* The acr username */
  connection_string               = module.az_mssql_secondary.connection_string_failover    /* MODULE IMPORT - db connection string */
  autoscale_name                  = "autoscale-${var.location_secondary}"                   /* The autoscale setting name */
}

# Create dns records.
module "az_dns" {
  source                          = "../../mod/az_dns"                                      /* The path to the module */
  fd_name                         = "fd-${var.unique_id}"                                   /* The front door name */
}

# Create front door.
module "az_front_door" {
  source                          = "../../mod/az_front_door"                               /* The path to the module */
  depends_on                      = [module.az_appservice_primary,
                                     module.az_appservice_secondary,
                                     module.az_dns]
  resource_group_name             = azurerm_resource_group.rg.name                          /* The resource group */
  fd_name                         = "fd-${var.unique_id}"                                   /* The front door name */
  be_prd_rhod3rz_com_pri          = "${module.az_config.item_name.ase_primary}"             /* The webapp name - prd pri */
  be_prd_rhod3rz_com_sec          = "${module.az_config.item_name.ase_secondary}"           /* The webapp name - prd sec */
  be_stg_rhod3rz_com_pri          = "${module.az_config.item_name.ase_primary}-stg"         /* The webapp name - stg pri */
  be_stg_rhod3rz_com_sec          = "${module.az_config.item_name.ase_secondary}-stg"       /* The webapp name - stg sec */
}
