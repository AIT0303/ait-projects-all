# Import existing AdministratorAccess Permission Set
import {
  to = aws_ssoadmin_permission_set.admin
  id = "arn:aws:sso:::permissionSet/ssoins-7758270a6e7c518e/ps-7758992fbbe732da,arn:aws:sso:::instance/ssoins-7758270a6e7c518e"
}

# Import existing Managed Policy Attachment for AdministratorAccess
import {
  to = aws_ssoadmin_managed_policy_attachment.admin
  id = "arn:aws:iam::aws:policy/AdministratorAccess,arn:aws:sso:::permissionSet/ssoins-7758270a6e7c518e/ps-7758992fbbe732da,arn:aws:sso:::instance/ssoins-7758270a6e7c518e"
}
