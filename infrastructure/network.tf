
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

    delegation { 
        name = "delegation-containerapps" 
        service_delegation { 
            name = "Microsoft.App/environments" 
            actions = ["Microsoft.Network/virtualNetworks/subnets/action"] 
        } 
    }
}

resource "azurerm_subnet" "endpoint" {
    name = "endpoint-subnet"
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
resource "azurerm_public_ip" "order" {
    name = "order-pip"
    location = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    allocation_method = "Static"
    sku = "Standard"
}

resource "azurerm_network_interface" "order" {
    name = "example-nic-order"
    location = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.example.id 
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.order.id
    }
}


resource "azurerm_network_interface" "consumer" {
    name = "example-nic-consumer"
    location = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.example.id 
        private_ip_address_allocation = "Dynamic"
    }
}
*/