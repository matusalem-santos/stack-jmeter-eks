data "tls_certificate" "this" {
  url = var.url
}

resource "aws_iam_openid_connect_provider" "oidc" {
  url = var.url

  client_id_list = var.client_id_list

  thumbprint_list = length(var.thumbprint_list) > 0 ? var.thumbprint_list : [data.tls_certificate.this.certificates.0.sha1_fingerprint]

  tags = merge(var.tags,
  {
    Terraform = "true"
  },)
}