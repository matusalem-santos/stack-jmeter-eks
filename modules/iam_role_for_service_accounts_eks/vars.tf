variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "policy_identifiers" {
  type        = string
  description = "The ID of the master account to Read Only Access the current account."
}


variable "description" {
  type        = string
  default     = "The role to grant permissions to this account to delegated IAM users in the master account."
  description = "Description of IAM Role."
}

variable "policy_arns" {
  type        = set(string)
  description = "Policy ARN to attach to the role. By default it attaches `AdministratorAccess` managed policy to grant full access to AWS services and resources in the current account."
  default = []
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Enabled to create module or not."
}

variable "max_session_duration" {
  type        = string
  default     = "3600"
  description = " - (Optional) The maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours."
}

variable "force_detach_policies" {
  type        = bool
  default     = false
  description = "(Optional) Specifies to force detaching any policies the role has before destroying it. Defaults to false"
}

variable "role_name" {
    type = string
    description = "(optional) describe your variable"
}

variable "policy_type" {
  type = string
  description = "(optional) describe your variable"
}

variable "role_action" {
  type        = string
  description = "The ID of the master account to Read Only Access the current account."
  default     = "sts:AssumeRole"
}

variable "effect" {
  type        = string
  description = "Whether this statement allows or denies the given actions. Valid values are Allow and Deny"
  default     = "Allow"
}

variable "conditions" {
  type        = list(any)
  description = "Conditions can be specific to an AWS service. When using multiple condition blocks, they must all evaluate to true for the policy statement to apply."
  default     = []
}