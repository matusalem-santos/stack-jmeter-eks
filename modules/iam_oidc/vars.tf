variable "url" {
    type = string
    description = "The URL of the identity provider. Corresponds to the iss claim"
}

variable "client_id_list" {
    type = list(string)
    default = []
    description = "A list of client IDs (also known as audiences). When a mobile or web app registers with an OpenID Connect provider, they establish a value that identifies the application. (This is the value that's sent as the client_id parameter on OAuth requests.)"
}

variable "thumbprint_list" {
    type = list(string)
    default = []
    description = "A list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s)."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags."
}