locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.subnet_count)

  tags = {
    Environment = var.Environment
  }
}
