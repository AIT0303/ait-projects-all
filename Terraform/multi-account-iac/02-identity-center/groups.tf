# Admin Group
resource "aws_identitystore_group" "admins" {
  display_name      = "Admins"
  description       = "Administrators group"
  identity_store_id = local.identity_store_id
}

# Developers Group
resource "aws_identitystore_group" "developers" {
  display_name      = "Developers"
  description       = "Developers group"
  identity_store_id = local.identity_store_id
}

# Auditors Group (Read Only)
resource "aws_identitystore_group" "auditors" {
  display_name      = "Auditors"
  description       = "Auditors with read-only access"
  identity_store_id = local.identity_store_id
}
