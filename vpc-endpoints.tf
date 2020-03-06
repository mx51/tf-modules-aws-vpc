resource "aws_security_group" "sgforendpoint" {
  name        = "EndpointSG"
  description = "Allow indbound and outbound traffic for VPC endpoint"
  vpc_id      = aws_vpc.main.id
  tags = merge(
    { Name = "${var.vpc_name}-EndpointSG" },
    var.tags
  )
}

resource "aws_security_group_rule" "allow_all_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sgforendpoint.id
}

resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sgforendpoint.id
}

resource "aws_security_group" "sgforendpoint_tls" {
  name        = "EndpointSG-TLS"
  description = "Allow indbound and outbound traffic for VPC endpoint requiring TLS"
  vpc_id      = aws_vpc.main.id
  tags = merge(
    { Name = "${var.vpc_name}-EndpointSG-TLS" },
    var.tags
  )
}
resource "aws_security_group_rule" "allow_all_ingress_tls" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sgforendpoint_tls.id
}

resource "aws_security_group_rule" "allow_all_egress_tls" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sgforendpoint_tls.id
}

resource "aws_vpc_endpoint" "vpc_endpoint" {
  for_each            = var.vpc_endpoints
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = "true"
  security_group_ids  = [aws_security_group.sgforendpoint.id]
  subnet_ids          = aws_subnet.private.*.id
  tags = merge(
    { Name = "${var.vpc_name}-${each.value}-endpoint" },
    var.tags
  )
}

resource "aws_vpc_endpoint" "vpc_endpoint_tls" {
  for_each            = var.vpc_endpoints_tls
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = "true"
  security_group_ids  = [aws_security_group.sgforendpoint_tls.id]
  subnet_ids          = aws_subnet.private.*.id
  tags = merge(
    { Name = "${var.vpc_name}-${each.value}-endpoint-tls" },
    var.tags
  )
}

resource "aws_vpc_endpoint" "vpc_gatewayendpoint" {
  for_each        = var.vpc_gatewayendpoints
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${var.aws_region}.${each.value}"
  route_table_ids = concat("${aws_route_table.private.*.id}", "${aws_route_table.secure.*.id}")
  tags = merge(
    { Name = "${var.vpc_name}-${each.value}-endpoint" },
    var.tags
  )
}

resource "aws_vpc_endpoint" "vpc_custom_endpoint" {
  for_each            = var.vpc_custom_endpoints
  vpc_id              = aws_vpc.main.id
  service_name        = each.value.service_name
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = each.value.private_dns_enabled
  security_group_ids  = [aws_security_group.sgforendpoint.id]
  subnet_ids          = aws_subnet.private.*.id
  tags = merge(
    { Name = "${var.vpc_name}-${each.key}-endpoint" },
    var.tags
  )
}
