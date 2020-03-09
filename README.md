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

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
| vpc_name | Name that will be prefixed to resources | string | n/a | yes |
| vpc_cidr_block | The CIDR block of the VPC | string | n/a | yes |
| vpc_enable_dns_support | Enable VPC DNS Resolver | bool | `true` | no |
| vpc_enable_dns_hostnames | Enable VPC DNS hostname resolution | bool | `true` | no |
| availability_zones | List of availability zones | set(string) | n/a | yes |
| vpc_endpoints | List of VPC Interface endpoints | set(string) | [] | no |
| vpc_endpoints_tls | List of VPC Interface endpoints requiring TLS | set(string) | [] | no |
| vpc_gatewayendpoints | List of VPC Gateway endpoints | set(string) | [] | no |
| public_tier_newbits | newbits value for calculating the public tier size | number | `2` | no |
| public_subnet_newbits | newbits value for calculating the public subnet size | number | `2` | no |
| private_tier_newbits | newbits value for calculating the private tier size | number | `2` | no |
| private_subnet_newbits | newbits value for calculating the private subnet size | number | `2` | no |
| secure_tier_newbits | newbits value for calculating the secure tier size | number | `2` | no |
| secure_subnet_newbits | newbits value for calculating the secure subnet size | number | `2` | no |
| enable_internet_gateway | Attach an internet gateway to the VPC | bool | `true` | no |
| enable_nat_gateway | Create NAT gateways in the VPC for private and public subnets | bool | `true` | no |
| enable_nat_gateway_on_secure_subnet | Create NAT gateways in the VPC for the secure subnet | bool | `false` | no |
| enable_per_az_nat_gateway | Create 1 NAT gateway per AZ | bool | `true` | no |
| enable_virtual_private_gateway | Attach a virtual private gateway to the VPC | bool | `false` | no |
| virtual_private_gateway_asn | ASN for the Amazon side of the VPG | number | `64512` | no |
| enable_custom_dhcp_options | Enable custom DHCP options, you must specify custom_dhcp_options | bool | `false` | no |
| custom_dhcp_options | Custom DHCP options | object({domain_name = string, domain_name_servers = list(string), ntp_servers = list(string), netbios_name_servers = list(string), netbios_node_type = number}) | {domain_name = null domain_name_servers = null ntp_servers = null netbios_name_servers = null netbios_node_type = null} | no |
| nacl_allow_all_vpc_traffic | Add a rule to all NACLs allowing all traffic to/from the VPC CIDR | bool | `true` | no |
| nacl_allow_all_ephemeral | Add a rule to all NACLs allowing all ephemeral ports | bool | `true` | no |
| nacl_allow_all_http_ingress | Add a rule to all NACLs allowing HTTP ingress | bool | `true` | no |
| nacl_allow_all_http_egress | Add a rule to all NACLs allowing HTTP egress | bool | `true` | no |
| nacl_allow_all_https_ingress | Add a rule to all NACLs allowing HTTPS ingress | bool | `true` | no |
| nacl_allow_all_https_egress | Add a rule to all NACLs allowing HTTPS egress | bool | `true` | no |
| nacl_allow_all_ssh_egress | Add a rule to all NACLs allowing SSH egress | bool | `false` | no |
| nacl_block_public_to_secure | Block all traffic between public and secure tiers | bool | `false` | no |
| nacl_public_custom | List of custom nacls to apply to the public tier | list(object({rule_number = number, egress = bool, protocol = any, rule_action = string, cidr_block = string, from_port = string, to_port = string})) | `null` | no |
| nacl_private_custom | List of custom nacls to apply to the private tier | list(object({rule_number = number, egress = bool, protocol = any, rule_action = string, cidr_block = string, from_port = string, to_port = string})) | `null` | no |
| nacl_secure_custom | List of custom nacls to apply to the secure tier | list(object({rule_number = number, egress = bool, protocol = any, rule_action = string, cidr_block = string, from_port = string, to_port = string})) | `null` | no |
| enable_db_secure_subnet_group | Create a DB subnet group  | bool | `false` | no |
| enable_vpc_flow_log | Enable VPC FLow logs to be stored into S3 bucket  | bool | `false` | no |
| flow_log_bucket_name | S3 bucket name to hold VPC Flow logs. Bucket name will be prefaced by the vpc id  | string | n/a | yes |
| enable_bucket_versioning | Enable s3 bucket versioning  | bool | `true` | yes |
| enable_lifecycle_rule | Enable s3 lifecycle rule  | bool | `true` | yes |
| lifecycle_prefix | Prefix filter. Used to manage object lifecycle events  | string | ` ` | yes |
| lifecycle_tags | Tags filter. Used to manage object lifecycle events  | map(string) | {} | yes |
| noncurrent_version_expiration_days | Specifies when noncurrent object versions expire  | int | 90 | yes |
| noncurrent_version_transition_days | Specifies when noncurrent object versions transitions  | int | 30 | yes |
| standard_transition_days | Number of days to persist in the standard storage tier before moving to the infrequent access tier  | int | 30 | yes |
| glacier_transition_days | Number of days after which to move the data to the glacier storage tier  | int | 60 | yes |
| expiration_days | Number of days after which to expunge the objects  | int | 90 | yes |

| tags | Tags applied to all resources | map(string) | `{}` | no |

## Outputs
| Name | Description |
|------|-------------|
| public_tier_subnet | Calculated CIDR range of the public tier |
| private_tier_subnet | Calculated CIDR range of the private tier |
| secure_tier_subnet | Calculated CIDR range of the secure tier |

## Development
Most of the Terraform ecosystem does not yet support 0.12. You need to manually update Inputs/Outputs when you add variables until terraform-docs supports 0.12.

## Network Access Controls Lists

Network Access Control Lists (NACL) provide an additional layer of security by providing subnet level firewalling. NACL's will be used to ensure that the defence in depth network architecture is enforced. NACL's are applied in order of rule number with the processing stopping at the first matched rule, which means that a standardised rule numbering is required to ensure new rules can be added as required.

NACL's are stateless, which means return traffic is not implicitly allowed and both inbound and outbound traffic flows must be defined for all communication. There are limits on the number of NACL rules which can be defined on a single subnet, additionally NACL's can add a layer of complexity to the environment as firewall rules need to be managed at both the subnet and host layer. To reduce complexity, it is recommended to apply a standard NACL policy this defines the network tier level access and does not got down to the host / port level to ensure manageability and reduce the risk of running into rule count limits. 

### NACL Key:

| Key |	Block |	Allow |	Source | Traffic | Description |
|-----|-------|-------|--------|---------|-------------|
| 1XX	| 100-149	| 150-199	| IP	| Port | Local VPC Traffic |
| 2XX	| 200-249	| 250-299	| IP	| Port Range |
| 3XX	| 300-349	| 350-399	| IP	| ANY |
| 4XX	| 400-449	| 450-499	| IP Range | Port |
| 5XX	| 500-549	| 550-599	| IP Range | Port Range |
| 6XX	| 600-649	| 650-699	| IP Range	| Any |
| 7XX	| 700-749	| 750-799	| Peered IP	| Port | Peered VPC, VPN or direct connect traffic |
| 8XX	| 800-849	| 850-899	| Peered IP	| Port Range |
| 9XX	| 900-949	| 950-999	| Peered IP	| Any |
| 10XX	| 1000-1049	| 1050-1099	| Peered IP Range |	Port |
| 11XX	| 1100-1149	| 1150-1199	| Peered IP Range |	Port Range |
| 12XX	| 1200-1249	| 1250-1299	| Peered IP Range |	Any |
| 13XX	| 1300-1349	| 1350-1399	| External IP |	Port | Known third party network
| 14XX	| 1400-1449	| 1450-1499	| External IP |	Port Range |
| 15XX	| 1500-1549	| 1550-1599	| External IP |	Any |
| 16XX	| 1600-1649	| 1650-1699	| External IP Range	| Port
| 17XX	| 1700-1749	| 1750-1799	| External IP Range	| Port Range |
| 18XX	| 1800-1849	| 1850-1899	| External IP Range	| Any |
| 19XX	| 1900-1949	| 1950-1999	| Any | Port |	Any external host including internet traffic |
| 20XX	| 2000-2049	| 2050-2099	| Any |	Port Range |
| 21XX	| 2100-2149	| 2150-2199	| Any |	Any |
