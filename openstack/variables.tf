variable "external_gateway" {
  description = "ID of the external network"
  type        = string
  default     = "dummy-id"
}

variable "dns_ip" {
  description = "List of DNS IP addresses"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "network_http" {
  description = "Configuration for the HTTP network"
  type        = map(string)
  default = {
    subnet_name = "subnet-http"
    cidr        = "192.168.1.0/24"
  }
}