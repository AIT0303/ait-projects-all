# Administrator Access Permission Set
resource "aws_ssoadmin_permission_set" "admin" {
  name             = "AdministratorAccess"
  description      = "Full administrator access"
  instance_arn     = local.instance_arn
  session_duration = "PT8H" # 8 hours

  tags = {
    Name = "AdministratorAccess"
  }
}

resource "aws_ssoadmin_managed_policy_attachment" "admin" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
}

# Read Only Access Permission Set
resource "aws_ssoadmin_permission_set" "readonly" {
  name             = "ReadOnlyAccess"
  description      = "Read only access for viewing resources"
  instance_arn     = local.instance_arn
  session_duration = "PT8H"

  tags = {
    Name = "ReadOnlyAccess"
  }
}

resource "aws_ssoadmin_managed_policy_attachment" "readonly" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
}

# Developer Access Permission Set (PowerUser without IAM)
resource "aws_ssoadmin_permission_set" "developer" {
  name             = "DeveloperAccess"
  description      = "Developer access - PowerUser without IAM modifications"
  instance_arn     = local.instance_arn
  session_duration = "PT8H"

  tags = {
    Name = "DeveloperAccess"
  }
}

resource "aws_ssoadmin_managed_policy_attachment" "developer" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  permission_set_arn = aws_ssoadmin_permission_set.developer.arn
}
