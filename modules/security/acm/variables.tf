variable "environment" {
  description = "Environment name"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name for the certificate"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9.-]+$", var.domain_name))
    error_message = "Domain name must be a valid hostname."
  }
}

variable "cloudfront_subject_alternative_names" {
  description = "Subject Alternative Names for the CloudFront certificate"
  type        = list(string)
  default     = []

  validation {
    condition = length(var.cloudfront_subject_alternative_names) == 0 || alltrue([
      for san in var.cloudfront_subject_alternative_names : can(regex("^[a-z0-9.-]+$", san))
    ])
    error_message = "All CloudFront subject alternative names must be valid hostnames."
  }
}

variable "alb_subject_alternative_names" {
  description = "Subject Alternative Names for the ALB certificate"
  type        = list(string)
  default     = []

  validation {
    condition = length(var.alb_subject_alternative_names) == 0 || alltrue([
      for san in var.alb_subject_alternative_names : can(regex("^[a-z0-9.-]+$", san))
    ])
    error_message = "All ALB subject alternative names must be valid hostnames."
  }
}

variable "zone_id" {
  description = "Route53 hosted zone ID for DNS validation"
  type        = string

  validation {
    condition     = can(regex("^Z[A-Z0-9]+$", var.zone_id))
    error_message = "Zone ID must be a valid Route53 hosted zone ID."
  }
}

variable "validation_method" {
  description = "Method to use for domain validation (DNS or EMAIL)"
  type        = string
  default     = "DNS"

  validation {
    condition     = contains(["DNS", "EMAIL"], var.validation_method)
    error_message = "Validation method must be either DNS or EMAIL."
  }
}


variable "tags" {
  description = "Tags to apply to the certificate"
  type        = map(string)
  default     = {}
}
