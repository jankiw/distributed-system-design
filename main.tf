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
    name = "internal"
    resource_group_name = azurerm_resource_group.example.name
    virtual_network_name = azurerm_virtual_network.example.name
    address_prefixes = var.vnet_address_prefixes
}

resource "azurerm_public_ip" "vm" {
    count = 3
    name = "vm-pip-${count.index}"
    location = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    allocation_method = "Static"
    sku = "Standard"
}

resource "azurerm_network_interface" "example" {
    count = 3
    name = "example-nic-${count.index}"
    location = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.example.id 
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.vm[count.index].id
    }
}

resource "azurerm_linux_virtual_machine" "example" {
    count = 3
    name = "example-vm-${count.index}"
    location = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    network_interface_ids = [azurerm_network_interface.example[count.index].id]
    size = "Standard_B1s"
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

resource "azurerm_postgresql_flexible_server" "postgresql" {
    name = "example-postgresql"
    location = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    administrator_login = "psqladmin"
    administrator_password = "P@sSw0rd243%"
    sku_name = "GP_Standard_D2s_v3"
    version = "13"
    storage_mb = 32768
    delegated_subnet_id = azurerm_subnet.example.id
}

resource "azurerm_postgresql_database" "exampledb" {
    name = "exampledb"
    resource_group_name = azurerm_resource_group.example.name
    server_name = azurerm_postgresql_flexible_server.postgresql.name
    charset = "UTFS"
    collation = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "allow_vm" {
    name = "allow-vm"
    resource_group_name = azurerm_resource_group.example.name
    server_name = azurerm_postgresql_flexible_server.postgresql.name
    start_ip_address = azurerm_public_ip.vm[0].ip_address
    end_ip_address = azurerm_public_ip.vm[2].ip_address
}