/*
resource "azurerm_linux_virtual_machine" "example" {
    count = 3
    name = "example-vm-${count.index}"
    location = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    network_interface_ids = [azurerm_network_interface.example[count.index].id]
    size = "Standard_F2"
    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    source_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "18.04-LTS"
        version = "latest"
    }
    disable_password_authentication = false
    admin_username = "azureuser"
    admin_password = "P@sSw0rd243%"

    tags = {
        enviroment = "dev"
    }
    provisioner "remote-exec" {
        inline = [
            "sudo apt update",
            "sudo apt install postgresql-client -y",
            "echo 'export DB_HOST=${azurerm_postgresql_flexible_server.postgresql.fqdn}' >> ~/.bashrc",
            "echo 'export DB_USER=psqladmin' >> ~/.bashrc",
            "echo 'export DB_PASSWORD=P@sSw0rd243%' >> ~/.bashrc",
            "source ~/.bashrc"
        ]
    }
}
*/
/*
resource "azurerm_log_analytics_workspace" "example" {
  name                = "acctest-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
*/

resource "azurerm_container_app_environment" "example" {
  name                       = "Example-Environment"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  #log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}

resource "azurerm_container_app" "example" {
  name                         = "example-app"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = azurerm_resource_group.example.name
  revision_mode                = "Single"

  template {
    container {
      name   = "examplecontainerapp"
      image  = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}