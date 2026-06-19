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

resource "azurerm_log_analytics_workspace" "example" {
  name                = "dsd-log-analytics"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "example" {
  name                       = "Example-dsd-Environment1"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  infrastructure_subnet_id = azurerm_subnet.example.id
}

resource "azurerm_container_app" "notifications" {
  name                         = "my-dsd-notifications"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = azurerm_resource_group.example.name
  revision_mode                = "Single"

  template {
    container {
      name   = "examplecontainerapp"
      image  = "ghcr.io/jankiw/distributed-system-design:notification"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name = "SERVICE_BUS_CONNECTION_STRING"
        value = var.bus_string
      }

      env {
        name = "ACS_CONNECTION_STRING"
        value = var.acs_string
      }

      env {
        name = "ACS_SENDER_ADDRESS"
        value = var.acs_addr
      }

      env {
        name = "DATABASE_URI"
        value = local.database_uri
      }
    }
  }
}

resource "azurerm_container_app" "payments" {
  name                         = "my-dsd-payments"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = azurerm_resource_group.example.name
  revision_mode                = "Single"

  template {
    container {
      name   = "examplecontainerapp"
      image  = "ghcr.io/jankiw/distributed-system-design:payment"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name = "SERVICE_BUS_CONNECTION_STRING"
        value = var.bus_string
      }

      env {
        name = "ACS_CONNECTION_STRING"
        value = var.acs_string
      }

      env {
        name = "ACS_SENDER_ADDRESS"
        value = var.acs_addr
      }

      env {
        name = "DATABASE_URI"
        value = local.database_uri
      }
    }
  }
}

resource "azurerm_container_app" "consumer" {
  name                         = "my-dsd-consumer"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = azurerm_resource_group.example.name
  revision_mode                = "Single"

  template {
    container {
      name   = "examplecontainerapp"
      image  = "ghcr.io/jankiw/distributed-system-design:consumer"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name = "SERVICE_BUS_CONNECTION_STRING"
        value = var.bus_string
      }

      env {
        name = "ACS_CONNECTION_STRING"
        value = var.acs_string
      }

      env {
        name = "ACS_SENDER_ADDRESS"
        value = var.acs_addr
      }

      env {
        name = "DATABASE_URI"
        value = local.database_uri
      }
    }
  }
}

resource "azurerm_container_app" "order" {
  name                         = "my-dsd-order"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = azurerm_resource_group.example.name
  revision_mode                = "Single"

  template {
    container {
      name   = "examplecontainerapp"
      image  = "ghcr.io/jankiw/distributed-system-design:order"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name = "SERVICE_BUS_CONNECTION_STRING"
        value = var.bus_string
      }

      env {
        name = "ACS_CONNECTION_STRING"
        value = var.acs_string
      }

      env {
        name = "ACS_SENDER_ADDRESS"
        value = var.acs_addr
      }

      env {
        name = "DATABASE_URI"
        value = local.database_uri
      }
    }
  }
}

resource "azurerm_private_endpoint" "example" {
  name                = "example-dsd-endpoint"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.endpoint.id

  private_service_connection {
    name                           = "example-privateserviceconnection"
    private_connection_resource_id = azurerm_container_app.order.id
    is_manual_connection           = false
  }
}