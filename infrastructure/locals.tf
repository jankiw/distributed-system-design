locals {
  app_service_plan_name = "asp-${var.streamlit_name}"
  linux_web_app_name = "app-${var.streamlit_name}"
  db_password_encoded = replace(replace(azurerm_postgresql_flexible_server.postgresql.administrator_password, "%", "%25"), "@", "%40")
  database_uri = "postgresql://${azurerm_postgresql_flexible_server.postgresql.administrator_login}:${local.db_password_encoded}@${azurerm_postgresql_flexible_server.postgresql.name}.privatelink.postgres.database.azure.com:5432/${azurerm_postgresql_flexible_server_database.exampledb.name}"
  app_settings = {
    ENV = var.environment
    SERVICE_BUS_CONNECTION_STRING = var.bus_string
    ACS_CONNECTION_STRING = var.acs_string
    ACS_SENDER_ADDRESS = var.acs_addr
    DATABASE_URI = database_uri
  }
}