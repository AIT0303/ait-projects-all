# =============================================================================
# Admin Group Assignments
# =============================================================================

# Admins -> Management Account (Administrator)
resource "aws_ssoadmin_account_assignment" "admins_management" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_id       = aws_identitystore_group.admins.group_id
  principal_type     = "GROUP"
  target_id          = data.aws_caller_identity.current.account_id
  target_type        = "AWS_ACCOUNT"
}

# Admins -> Dev Account (Administrator)
resource "aws_ssoadmin_account_assignment" "admins_dev" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_id       = aws_identitystore_group.admins.group_id
  principal_type     = "GROUP"
  target_id          = local.dev_account_id
  target_type        = "AWS_ACCOUNT"
}

# Admins -> Prod Account (Administrator)
resource "aws_ssoadmin_account_assignment" "admins_prod" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_id       = aws_identitystore_group.admins.group_id
  principal_type     = "GROUP"
  target_id          = local.prod_account_id
  target_type        = "AWS_ACCOUNT"
}

# Admins -> Audit Account (Administrator)
resource "aws_ssoadmin_account_assignment" "admins_audit" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_id       = aws_identitystore_group.admins.group_id
  principal_type     = "GROUP"
  target_id          = local.audit_account_id
  target_type        = "AWS_ACCOUNT"
}

# Admins -> Log Archive Account (Administrator)
resource "aws_ssoadmin_account_assignment" "admins_log_archive" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_id       = aws_identitystore_group.admins.group_id
  principal_type     = "GROUP"
  target_id          = local.log_archive_account_id
  target_type        = "AWS_ACCOUNT"
}

# =============================================================================
# Developer Group Assignments
# =============================================================================

# Developers -> Dev Account (Developer Access)
resource "aws_ssoadmin_account_assignment" "developers_dev" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.developer.arn
  principal_id       = aws_identitystore_group.developers.group_id
  principal_type     = "GROUP"
  target_id          = local.dev_account_id
  target_type        = "AWS_ACCOUNT"
}

# Developers -> Prod Account (Read Only)
resource "aws_ssoadmin_account_assignment" "developers_prod_readonly" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
  principal_id       = aws_identitystore_group.developers.group_id
  principal_type     = "GROUP"
  target_id          = local.prod_account_id
  target_type        = "AWS_ACCOUNT"
}

# =============================================================================
# Auditor Group Assignments
# =============================================================================

# Auditors -> All Accounts (Read Only)
resource "aws_ssoadmin_account_assignment" "auditors_management" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
  principal_id       = aws_identitystore_group.auditors.group_id
  principal_type     = "GROUP"
  target_id          = data.aws_caller_identity.current.account_id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "auditors_dev" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
  principal_id       = aws_identitystore_group.auditors.group_id
  principal_type     = "GROUP"
  target_id          = local.dev_account_id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "auditors_prod" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
  principal_id       = aws_identitystore_group.auditors.group_id
  principal_type     = "GROUP"
  target_id          = local.prod_account_id
  target_type        = "AWS_ACCOUNT"
}
