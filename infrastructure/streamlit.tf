resource "azurerm_service_plan" "service_plan" {
  name                = local.app_service_plan_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  os_type             = "Linux"
  sku_name            = var.app_service_plan_sku_name
  tags = {}
}

resource "random_id" "random_chars_web_app_name" {
  byte_length = 2
}

resource "azurerm_linux_web_app" "web-app" {
  name                = "my-dsd-streamlit"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  service_plan_id     = azurerm_service_plan.service_plan.id
  app_settings        = merge(local.app_settings, var.app_settings)

  site_config {
    always_on        = true # always_on cannot be set to true when using Free, F1, D1 Sku
    application_stack {
      docker_image_name = var.streamlit_docker_image_name
      docker_registry_url = var.docker_registry_url
      docker_registry_username = var.use_docker_registry_auth ? var.docker_registry_username : null
      docker_registry_password = var.use_docker_registry_auth ? var.docker_registry_password : null
    }
  }
}