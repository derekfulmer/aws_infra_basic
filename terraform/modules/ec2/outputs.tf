output "host_list" {
  value = [for host in aws_instance.host : aws_instance.host]
}

