output "item_name" {
  value = {
    resource_group             = lower("rg-${var.environment}-${var.application_code}-${var.unique_id}")
    sql_server_primary         = lower("sql-${var.environment}-${lookup(var.region_shortname_mapping, var.location_primary)}-${var.application_code}-${var.unique_id}")
    sql_server_secondary       = lower("sql-${var.environment}-${lookup(var.region_shortname_mapping, var.location_secondary)}-${var.application_code}-${var.unique_id}")
    law_primary                = lower("log-${var.environment}-${lookup(var.region_shortname_mapping, var.location_primary)}-${var.application_code}-${var.unique_id}")
    law_secondary              = lower("log-${var.environment}-${lookup(var.region_shortname_mapping, var.location_secondary)}-${var.application_code}-${var.unique_id}")
    asp_primary                = lower("plan-${var.environment}-${lookup(var.region_shortname_mapping, var.location_primary)}-${var.application_code}-${var.unique_id}")
    asp_secondary              = lower("plan-${var.environment}-${lookup(var.region_shortname_mapping, var.location_secondary)}-${var.application_code}-${var.unique_id}")
    ase_primary                = lower("ase-${var.environment}-${lookup(var.region_shortname_mapping, var.location_primary)}-${var.application_code}-${var.unique_id}")
    ase_secondary                = lower("ase-${var.environment}-${lookup(var.region_shortname_mapping, var.location_secondary)}-${var.application_code}-${var.unique_id}")
  }
}

output "tags" {
  value = {
    "1-PointOfContact"         = var.point_of_contact
    "2-BillingCode"            = var.billing_code
    "3-ApplicationCode"        = var.application_code
    "4-Environment"            = var.environment
  }
}
