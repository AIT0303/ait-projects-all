# Import existing OUs
# Run: terraform plan to see import actions, then terraform apply

import {
  to = aws_organizations_organizational_unit.workloads
  id = "ou-f2qy-5lkxwb3b"
}

import {
  to = aws_organizations_organizational_unit.dev
  id = "ou-f2qy-b0o7lyoi"
}

import {
  to = aws_organizations_organizational_unit.prod
  id = "ou-f2qy-uvsgmhrl"
}

import {
  to = aws_organizations_organizational_unit.security
  id = "ou-f2qy-60c9lhcr"
}

import {
  to = aws_organizations_organizational_unit.sandbox
  id = "ou-f2qy-4odunbrs"
}
