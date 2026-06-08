variable "resource_group_name" {
    default = "example-rg"
}

variable "location" {
    default = "polandcentral"
}

variable "vnet_address_space" {
    default = ["10.0.0.0/16"]
}

variable "example_address_prefixes" {
    default = ["10.0.2.0/24"]
}

variable "postgresql_address_prefixes" {
    default = ["10.0.3.0/24"]
}
