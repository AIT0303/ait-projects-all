# =============================================================================
# SCP: Deny Leave Organization
# =============================================================================
resource "aws_organizations_policy" "deny_leave_org" {
  name        = "DenyLeaveOrganization"
  description = "Prevent accounts from leaving the organization"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/policies/deny-leave-org.json")

  tags = {
    Name = "DenyLeaveOrganization"
  }
}

# Attach to Workloads OU (applies to all child OUs)
resource "aws_organizations_policy_attachment" "deny_leave_org_workloads" {
  policy_id = aws_organizations_policy.deny_leave_org.id
  target_id = local.ou_workloads_id
}

# =============================================================================
# SCP: Deny Root User in Production
# =============================================================================
resource "aws_organizations_policy" "deny_root_prod" {
  name        = "DenyRootUserProduction"
  description = "Deny all actions by root user in production accounts"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/policies/deny-root-prod.json")

  tags = {
    Name = "DenyRootUserProduction"
  }
}

# Attach only to Production OU
resource "aws_organizations_policy_attachment" "deny_root_prod" {
  policy_id = aws_organizations_policy.deny_root_prod.id
  target_id = local.ou_prod_id
}

# =============================================================================
# SCP: Deny Unapproved Regions
# =============================================================================
resource "aws_organizations_policy" "deny_regions" {
  name        = "DenyUnapprovedRegions"
  description = "Restrict resource creation to approved regions only"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/policies/deny-regions.json")

  tags = {
    Name = "DenyUnapprovedRegions"
  }
}

# Attach to Workloads OU
resource "aws_organizations_policy_attachment" "deny_regions_workloads" {
  policy_id = aws_organizations_policy.deny_regions.id
  target_id = local.ou_workloads_id
}
