# CloudFront Certificate Outputs
output "cloudfront_certificate_arn" {
  description = "The ARN of the CloudFront certificate (us-east-1)"
  value       = aws_acm_certificate_validation.cloudfront.certificate_arn
}

output "cloudfront_certificate_id" {
  description = "The ID of the CloudFront certificate"
  value       = aws_acm_certificate.cloudfront.id
}

output "cloudfront_certificate_domain_name" {
  description = "The domain name of the CloudFront certificate"
  value       = aws_acm_certificate.cloudfront.domain_name
}

output "cloudfront_certificate_status" {
  description = "The status of the CloudFront certificate"
  value       = aws_acm_certificate.cloudfront.status
}

# ALB Certificate Outputs
output "alb_certificate_arn" {
  description = "The ARN of the ALB certificate"
  value       = aws_acm_certificate_validation.alb.certificate_arn
}

output "alb_certificate_id" {
  description = "The ID of the ALB certificate"
  value       = aws_acm_certificate.alb.id
}

output "alb_certificate_domain_name" {
  description = "The domain name of the ALB certificate"
  value       = aws_acm_certificate.alb.domain_name
}

output "alb_certificate_status" {
  description = "The status of the ALB certificate"
  value       = aws_acm_certificate.alb.status
}

