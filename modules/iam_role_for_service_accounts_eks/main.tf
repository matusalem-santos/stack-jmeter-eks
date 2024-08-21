
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = [
      var.role_action,
    ]
    principals {
      type        = var.policy_type
      identifiers = [var.policy_identifiers]
    }
    dynamic "condition" {
      for_each = var.conditions
      content {
        test      = condition.value["test"]
        variable  = condition.value["variable"]
        values    = condition.value["values"]
      }
    }
    effect = var.effect
  }
}

#Module      : AWS IAM ROLE
#Description : Provides an IAM role.
resource "aws_iam_role" "default" {
  count                 = var.enabled ? 1 : 0
  name                  = var.role_name
  assume_role_policy    = data.aws_iam_policy_document.assume_role.json
  description           = var.description
  tags = merge(var.tags,
  {
    Terraform = "true"
  },)
  force_detach_policies = var.force_detach_policies
  max_session_duration  = var.max_session_duration
}

#Module      : AWS IAM ROLE POLICY ATTACHMENT
#Description : PAttaches a Managed IAM Policy to an IAM role.
resource "aws_iam_role_policy_attachment" "default" {
  for_each   = var.policy_arns

  role       = aws_iam_role.default.*.name[0]
  policy_arn = each.key
}