locals {
  app_service_plan_name = "asp-${var.streamlit_name}"
  linux_web_app_name = "app-${var.streamlit_name}"
  app_settings = {
    ENV = var.environment
  }
}