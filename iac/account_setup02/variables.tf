variable "Environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "app_name" {
  description = "Name used for naming resources"
  type        = string
}

variable "subnet_count" {
  description = "Number of subnets to create"
  type        = number
  default     = 3
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "10.0.0.0/16"
}
