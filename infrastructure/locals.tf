locals {
  app_service_plan_name = "asp-${var.streamlit_name}"
  linux_web_app_name = "app-${var.streamlit_name}"
  app_settings = {
    ENV = var.environment
    SERVICE_BUS_CONNECTION_STRING = var.bus_string
    ACS_CONNECTION_STRING = var.acs_string
    ACS_SENDER_ADDRESS = var.acs_addr
    DATABASE_URI = var.db_uri
  }
}