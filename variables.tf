variable "region" {
  description = "region of instance"
}

variable "project_id" {
  description = "project id of this project"
}

variable "zone" {
  description = "zone in region"
}

variable "domain" {
  description = "domain of this application web"
}

variable "subdomain" {
  description = "subdomain of this application web"
  default     = "lb"
}

variable "network_name" {
  description = "name of netfwork"
  default     = "vpc-wordpress"
}

variable "subnet" {
  description = "subnet in a vpc"
  default     = "192.168.0.0/24"
}

variable "app-name" {
  default = "wordpress"
}

variable "instance_type" {
  description = "type of instance"
  default     = "e2-micro"
}
