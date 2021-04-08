output "id" {
    value = aws_subnet.aws_subnet.*.id
}

output "arn" {
    value = aws_subnet.aws_subnet.*.arn
}

output "cidr_block" {
    value = aws_subnet.aws_subnet.*.cidr_block
}

output "availability_zone" {
    value = aws_subnet.aws_subnet.*.availability_zone
}

output "map_public_ip_on_launch" {
    value = aws_subnet.aws_subnet.*.map_public_ip_on_launch
}