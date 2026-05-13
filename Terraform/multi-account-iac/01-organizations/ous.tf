# Get the organization root
data "aws_organizations_organization" "current" {}

# Workloads OU (parent for Dev/Prod)
resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = data.aws_organizations_organization.current.roots[0].id
}

# Development OU
resource "aws_organizations_organizational_unit" "dev" {
  name      = "Development"
  parent_id = aws_organizations_organizational_unit.workloads.id
}

# Production OU
resource "aws_organizations_organizational_unit" "prod" {
  name      = "Production"
  parent_id = aws_organizations_organizational_unit.workloads.id
}

# Security OU
resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = data.aws_organizations_organization.current.roots[0].id
}

# Sandbox OU (for experimentation)
resource "aws_organizations_organizational_unit" "sandbox" {
  name      = "Sandbox"
  parent_id = data.aws_organizations_organization.current.roots[0].id
}
