provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "example" {
    name = var.resource_group_name
    location = var.location
}

resource "azurerm_virtual_network" "example" {
    name = "example-network"
    address_space = var.vnet_address_space
    location = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
    name = "service-subnet"
    resource_group_name = azurerm_resource_group.example.name
    virtual_network_name = azurerm_virtual_network.example.name
    address_prefixes = var.example_address_prefixes
}

resource "azurerm_subnet" "postgresql" {
    name = "postgresql-subnet"
    resource_group_name = azurerm_resource_group.example.name
    virtual_network_name = azurerm_virtual_network.example.name
    address_prefixes = var.postgresql_address_prefixes

    delegation {
    name = "postgresql-delegation"

    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

/*
resource "azurerm_public_ip" "vm" {
    count = 3
    name = "vm-pip-${count.index}"
    location = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    allocation_method = "Static"
    sku = "Standard"
}
*/

resource "azurerm_network_interface" "example" {
    count = 3
    name = "example-nic-${count.index}"
    location = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.example.id 
        private_ip_address_allocation = "Dynamic"
        #public_ip_address_id = azurerm_public_ip.vm[count.index].id
    }
}

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

resource "azurerm_private_dns_zone" "postgresql" {
  name = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql" {
  name = "example-link"
  resource_group_name = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.postgresql.name
  virtual_network_id = azurerm_virtual_network.example.id
}

resource "azurerm_postgresql_flexible_server" "postgresql" {
    name = "example-dsd-postgresql"
    location = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    administrator_login = "psqladmin"
    administrator_password = "P@sSw0rd243%"
    sku_name = "GP_Standard_D2s_v3"
    version = "13"
    storage_mb = 32768
    delegated_subnet_id = azurerm_subnet.postgresql.id
    public_network_access_enabled = false
    private_dns_zone_id = azurerm_private_dns_zone.postgresql.id
}

resource "azurerm_postgresql_flexible_server_database" "exampledb" {
    name = "exampledb"
    server_id = azurerm_postgresql_flexible_server.postgresql.id
    charset = "utf8"
    collation = "en_US.utf8"
}

/*
resource "azurerm_postgresql_firewall_rule" "allow_vm" {
    name = "allow-vm"
    resource_group_name = azurerm_resource_group.example.name
    server_name = azurerm_postgresql_flexible_server.postgresql.name
    start_ip_address = azurerm_public_ip.vm[0].ip_address
    end_ip_address = azurerm_public_ip.vm[2].ip_address
}
*/