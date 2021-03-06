# terraform-aws-vpc

## Summary

This module deploys a 3-tier VPC. The following resources are managed:

- VPC
- Subnets
- Routes
- NACLs
- Internet Gateway
- NAT Gateways
- Virtual Private Gateway
- DHCP Option Sets
- VPC Endpoints
- DB Subnet Group

Tags on VPCs/Subnets are currently set to ignore changes. This is to support EKS clusters.

Terraform >= 0.12 is required for this module.

## CIDR Calculations

CIDR ranges are automatically calculated using Terraform's [`cidrsubnet()`](https://www.terraform.io/docs/configuration/functions/cidrsubnet.html) function. The default configuration results in equal-sized tiers that are -/2 smaller than the VPC. (A /16 VPC becomes a /18 tier.) Subnets are calculated with tierCIDR-/2. (A /18 tier becomes /20 subnets.) The number of subnets is determined by the number of `availability_zones` specified.

In the event that you do not want this topology, you can configure the `x_tier_newbits` and `x_subnet_newbits` options found in the inputs.

## Custom NACLs

NACLs in addition to the ones with input options can be added using the `nacl_x_custom` lists. The object schema is:

```tf
list(object({
    rule_number = number,
    egress = bool,
    protocol = number,
    rule_action = string,
    cidr_block = string,
    from_port = string,
    to_port = string}))
```

<!-- TERRAFORM-DOCS-GENERATION -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | >= 2.38.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.38.0 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_db_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/resources/db_subnet_group) |
| [aws_default_network_acl](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/resources/default_network_acl) |
| [aws_eip](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/resources/eip) |
| [aws_flow_log](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/resources/flow_log) |
| [aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/resources/internet_gateway) |
| [aws_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/resources/nat_gateway) |
| [aws_network_acl](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/resources/network_acl) |
| [aws_network_acl_rule](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/resources/network_acl_rule) |
| [aws_region](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/data-sources/region) |
| [aws_route](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/resources/route) |
| [aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/resources/route_table) |
| [aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/resources/route_table_association) |
| [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/resources/s3_bucket) |
| [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/resources/security_group) |
| [aws_security_group_rule](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/resources/security_group_rule) |
| [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/resources/subnet) |
| [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/resources/vpc) |
| [aws_vpc_dhcp_options](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/resources/vpc_dhcp_options) |
| [aws_vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/resources/vpc_endpoint) |
| [aws_vpn_gateway](https://registry.terraform.io/providers/hashicorp/aws/2.38.0/docs/resources/vpn_gateway) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| availability\_zones | List of availability zones | `set(string)` | n/a | yes |
| custom\_dhcp\_options | Custom DHCP options | <pre>object({<br>    domain_name          = string,<br>    domain_name_servers  = list(string),<br>    ntp_servers          = list(string),<br>    netbios_name_servers = list(string),<br>    netbios_node_type    = number<br>  })</pre> | <pre>{<br>  "domain_name": null,<br>  "domain_name_servers": null,<br>  "netbios_name_servers": null,<br>  "netbios_node_type": null,<br>  "ntp_servers": null<br>}</pre> | no |
| enable\_bucket\_versioning | Enable s3 bucket versioning | `bool` | `true` | no |
| enable\_custom\_dhcp\_options | Enable custom DHCP options, you must specify custom\_dhcp\_options | `bool` | `false` | no |
| enable\_db\_secure\_subnet\_group | Create a RDS DB subnet group | `bool` | `false` | no |
| enable\_default\_route\_from\_secure\_subnet | Enable default route to nat gateway from secure subnet | `bool` | `false` | no |
| enable\_internet\_gateway | Attach an internet gateway to the VPC | `bool` | `true` | no |
| enable\_lifecycle\_rule | Enable s3 lifecycle rule | `bool` | `true` | no |
| enable\_nat\_gateway | Create nat gateways in the VPC | `bool` | `true` | no |
| enable\_per\_az\_nat\_gateway | Create 1 nat gateway per AZ | `bool` | `true` | no |
| enable\_virtual\_private\_gateway | Attach a virtual private gateway to the VPC | `bool` | `false` | no |
| enable\_vpc\_flow\_log | Enable VPC FLow logs to be stored into S3 bucket | `bool` | `false` | no |
| expiration\_days | Number of days after which to expunge the objects | `number` | `90` | no |
| flow\_log\_bucket\_name | S3 bucket name to hold VPC Flow logs | `string` | `"flow-log-bucket"` | no |
| flow\_log\_external\_bucket | Name of the external bucket. Note, the bucket will need to allow the account where the VPC resides in as a trusted principal | `string` | `true` | no |
| glacier\_transition\_days | Number of days after which to move the data to the glacier storage tier | `number` | `60` | no |
| lifecycle\_prefix | Prefix filter. Used to manage object lifecycle events | `string` | `""` | no |
| lifecycle\_tags | Tags filter. Used to manage object lifecycle events | `map(string)` | `{}` | no |
| nacl\_allow\_all\_egress\_dns | Add a rule to all NACLs allowing egress to dns (tcp and udp) | `bool` | `false` | no |
| nacl\_allow\_all\_ephemeral | Add a rule to all NACLs allowing all ephemeral ports | `bool` | `true` | no |
| nacl\_allow\_all\_http\_egress | Add a rule to all NACLs allowing http egress | `bool` | `true` | no |
| nacl\_allow\_all\_http\_ingress | Add a rule to all NACLs allowing http ingress | `bool` | `true` | no |
| nacl\_allow\_all\_https\_egress | Add a rule to all NACLs allowing https egress | `bool` | `true` | no |
| nacl\_allow\_all\_https\_ingress | Add a rule to all NACLs allowing https ingress | `bool` | `true` | no |
| nacl\_allow\_all\_smtp\_egress | Add a rule to all NACLs allowing smtp egress | `bool` | `false` | no |
| nacl\_allow\_all\_ssh\_egress | Add a rule to all NACLs allowing ssh egress | `bool` | `false` | no |
| nacl\_allow\_all\_vpc\_traffic | Add a rule to all NACLs allowing all traffic to/from the vpc cidr | `bool` | `true` | no |
| nacl\_block\_public\_to\_secure | Block all traffic between public and secure tiers | `bool` | `false` | no |
| nacl\_private\_custom | List of custom nacls to apply to the private tier | <pre>list(object({<br>    rule_number = number,<br>    egress      = bool,<br>    protocol    = any,<br>    rule_action = string,<br>    cidr_block  = string,<br>    from_port   = string,<br>    to_port     = string<br>  }))</pre> | `null` | no |
| nacl\_public\_custom | List of custom nacls to apply to the public tier | <pre>list(object({<br>    rule_number = number,<br>    egress      = bool,<br>    protocol    = any, // can be "tcp" or 6<br>    rule_action = string,<br>    cidr_block  = string,<br>    from_port   = string,<br>    to_port     = string<br>  }))</pre> | `null` | no |
| nacl\_secure\_custom | List of custom nacls to apply to the secure tier | <pre>list(object({<br>    rule_number = number,<br>    egress      = bool,<br>    protocol    = any,<br>    rule_action = string,<br>    cidr_block  = string,<br>    from_port   = string,<br>    to_port     = string<br>  }))</pre> | `null` | no |
| noncurrent\_version\_expiration\_days | Specifies when noncurrent object versions expire | `number` | `90` | no |
| noncurrent\_version\_transition\_days | Specifies when noncurrent object versions transitions | `number` | `30` | no |
| private\_subnet\_newbits | newbits value for calculating the private subnet size | `number` | `2` | no |
| private\_tier\_newbits | newbits value for calculating the private tier size | `number` | `2` | no |
| public\_subnet\_newbits | newbits value for calculating the public subnet size | `number` | `2` | no |
| public\_tier\_newbits | newbits value for calculating the public tier size | `number` | `2` | no |
| secure\_subnet\_newbits | newbits value for calculating the secure subnet size | `number` | `2` | no |
| secure\_tier\_newbits | newbits value for calculating the secure tier size | `number` | `2` | no |
| send\_flow\_log\_to\_external\_bucket | Whether to send the flow log to an external created bucket | `bool` | `false` | no |
| standard\_transition\_days | Number of days to persist in the standard storage tier before moving to the infrequent access tier | `number` | `30` | no |
| tags | Tags applied to all resources | `map(string)` | `{}` | no |
| virtual\_private\_gateway\_asn | ASN for the Amazon side of the VPG | `number` | `64512` | no |
| vpc\_cidr\_block | The CIDR block of the VPC | `string` | n/a | yes |
| vpc\_custom\_endpoints | Map of VPC Custom Interface endpoints | <pre>map(object({<br>    service_name        = string<br>    private_dns_enabled = bool<br>  }))</pre> | `{}` | no |
| vpc\_enable\_dns\_hostnames | Enable VPC DNS hostname resolution | `bool` | `true` | no |
| vpc\_enable\_dns\_support | Enable VPC DNS resolver | `bool` | `true` | no |
| vpc\_endpoints | List of VPC Interface endpoints | `set(string)` | `[]` | no |
| vpc\_endpoints\_tls | List of VPC Interface endpoints requiring tls | `set(string)` | `[]` | no |
| vpc\_gatewayendpoints | List of VPC Gateway endpoints | `set(string)` | `[]` | no |
| vpc\_name | Name that will be prefixed to resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| private\_route\_table\_ids | n/a |
| private\_subnet\_ids | n/a |
| private\_tier\_subnet | n/a |
| public\_route\_table\_ids | n/a |
| public\_subnet\_ids | n/a |
| public\_tier\_subnet | n/a |
| secure\_db\_subnet\_group\_id | n/a |
| secure\_subnet\_ids | n/a |
| secure\_tier\_subnet | n/a |
| vpc\_cidr | n/a |
| vpc\_custom\_endpoint\_dns\_entries | n/a |
| vpc\_endpoint\_dns\_entries | n/a |
| vpc\_endpoints\_ids | n/a |
| vpc\_id | n/a |
