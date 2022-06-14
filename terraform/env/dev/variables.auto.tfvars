# Use variables.auto.tfvars to test locally.
# Duplicate these settings to azure devops variable groups as seen in the screenshots for use in pipelines.

# az_config
application_code       = "todolist"
billing_code           = "761"
environment            = "dev"
point_of_contact       = "admin@rhod3rz.com"
unique_id              = "220606-1000"
location_primary       = "eastus2"
location_secondary     = "centralus"

# az_mssql_primary
sql_db_name            = "todolistdb"
