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

resource "azurerm_network_interface" "example" {
    count = 3
    name = "example-nic-${count.index}"
    location = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.example.id 
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_storage_account" "storage" {
    name = "mydsdstorage"
    resource_group_name = azurerm_resource_group.example.name
    location = azurerm_resource_group.example.location
    account_tier = "Standard"
    account_replication_type = "LRS"
    tags = {
        enviroment = "dev"
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
    provisioner "local-exec" {
        command = <<EOT
echo "STORAGE_KEY=${azurerm_storage_account.storage.primary_access_key}">> /etc/environment
EOT
    }
}