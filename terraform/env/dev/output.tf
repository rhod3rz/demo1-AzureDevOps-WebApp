output "item_name"                     { value = module.az_config.item_name }
output "tags"                          { value = module.az_config.tags }

output "sql_database_db_id"            { value = module.az_mssql_primary.sql_database_db_id }
