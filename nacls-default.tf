resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  # no rules defined, deny all traffic in this ACL

  tags = merge(
    { Name = "${var.vpc_name}-default" },
    var.tags
  )
}
