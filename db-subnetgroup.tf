resource "aws_db_subnet_group" "main" {
  count      = var.enable_db_secure_subnet_group ? 1 : 0
  name       = var.db_secure_subnet_group_name
  subnet_ids = aws_subnet.secure.*.id
  tags = merge(
    { Name = var.db_secure_subnet_group_name != null ? "${var.db_secure_subnet_group_name}-db-secure-subnet-group" : "${count.index}-db-secure-subnet-group" },
    var.tags
  )
}
