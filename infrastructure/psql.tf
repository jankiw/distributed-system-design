
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
    high_availability = false
}

resource "azurerm_postgresql_flexible_server_database" "exampledb" {
    name = "exampledb"
    server_id = azurerm_postgresql_flexible_server.postgresql.id
    charset = "utf8"
    collation = "en_US.utf8"
}

resource "azurerm_private_endpoint" "example" {
  name                = "example-dsd-endpoint"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.endpoint.id

  private_service_connection {
    name                           = "example-privateserviceconnection"
    private_connection_resource_id = azurerm_postgresql_flexible_server.postgresql.id
    is_manual_connection           = false
    subresource_names              = ["postgresqlServer"]
  }
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