variable "resource_group_name" {
    default = "asdfgfdsa"
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

variable "endpoint_address_prefixes" {
    default = ["10.0.4.0/24"]
}

variable "streamlit_docker_image_name" {
  type        = string
  default     = "jankiw/distributed-system-design:streamlit"
}

variable "order_docker_image_name" {
  type        = string
  default     = "jankiw/distributed-system-design:order"
}

variable "docker_registry_url" {
  type        = string
  default     = "https://ghcr.io"
}

variable "use_docker_registry_auth" {
  type        = bool
  default     = false
}

variable "docker_registry_username" {
  type        = string
  default     = ""
}

variable "docker_registry_password" {
  type        = string
  default     = ""
  sensitive   = true
}

variable "app_settings" {
  type        = map(string)
  default     = {}
  description = "Application setting"
}

variable "app_service_plan_sku_name" {
  type        = string
  default     = "B1"
  validation {
    condition     = contains(["B1", "B2", "B3", "D1", "F1", "P1v2", "P2v2", "P3v2", "P0v3", "P1v3", "P2v3", "P3v3", "P1mv3", "P2mv3", "P3mv3", "P4mv3", "P5mv3"], var.app_service_plan_sku_name)
    error_message = "The app_service_plan_sku_name must be one of the following: B1, B2, B3, D1, F1, P1v2, P2v2, P3v2, P0v3, P1v3, P2v3, P3v3, P1mv3, P2mv3, P3mv3, P4mv3, P5mv3."
  }
}

variable "streamlit_name" {
  type        = string
  default     = "azure-streamlit"
}

variable "environment" {
  type        = string
  default     = "prod"
}

variable "bus_string" {}
variable "acs_string" {}
variable "acs_addr" {}