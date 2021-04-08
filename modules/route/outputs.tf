output "id" {
    value = aws_route.route.*.id
}

output "destination_cidr_block" {
    value = aws_route.route.*.destination_cidr_block
}