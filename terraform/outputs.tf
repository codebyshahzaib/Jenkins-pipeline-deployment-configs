output "ec2_public_ip" {
  description = "Public IP used by Jenkins and the browser"
  value       = aws_instance.app.public_ip
}

output "application_url" {
  description = "URL of the deployed application"
  value       = "http://${aws_instance.app.public_ip}"
}