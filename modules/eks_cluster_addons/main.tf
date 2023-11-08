resource "aws_eks_addon" "this" {
  for_each = { for k, v in var.cluster_addons : k => v }

  cluster_name = var.cluster_name
  addon_name   = try(each.value.name, each.key)

  addon_version                = lookup(each.value, "addon_version", null)
  resolve_conflicts_on_create  = lookup(each.value, "resolve_conflicts_on_create", null)
  resolve_conflicts_on_update  = lookup(each.value, "resolve_conflicts_on_update", null)
  service_account_role_arn     = lookup(each.value, "service_account_role_arn", null)
  depends_on = [var.eks_cluster_addons_depends_on]
}
