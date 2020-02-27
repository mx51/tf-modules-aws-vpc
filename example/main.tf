module "vpc" {
  source = "../"

  vpc_name       = "cmdlab-tf"
  vpc_cidr_block = "10.111.0.0/16"

  availability_zones = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]

  vpc_enable_dns_support   = true
  vpc_enable_dns_hostnames = true

  enable_virtual_private_gateway = true
  enable_nat_gateway             = true
  enable_per_az_nat_gateway      = true

  nacl_public_custom = [
    {
      rule_number = 1000
      egress      = false
      protocol    = 6
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 443
      to_port     = 443
    }
  ]
  enable_db_secure_subnet_group = true
  db_secure_subnet_group_name   = "dbsubnetgroupname"

  tags = {
    Owner      = "Foo"
    Department = "Bar"
  }
}
