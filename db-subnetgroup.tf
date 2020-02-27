resource "aws_db_subnet_group" "main" {
  count      = var.enable_db_secure_subnet_group ? 1 : 0
  name       = "${var.vpc_name}-db-secure-subnet-group"
  subnet_ids = aws_subnet.secure.*.id
  tags = merge(
    { Name = "${var.vpc_name}-db-secure-subnet-group" },
    var.tags
  )
}
