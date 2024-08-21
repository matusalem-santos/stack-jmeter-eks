output "arn" {
    value = aws_iam_openid_connect_provider.oidc.arn
}

output "thumbprint" {
    value = data.tls_certificate.this.certificates.0.sha1_fingerprint
}