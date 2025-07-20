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
}

variable "subject_alternative_names" {
  description = "Subject Alternative Names for the certificate"
  type        = list(string)
  default     = []
}

variable "zone_id" {
  description = "Route53 hosted zone ID for DNS validation"
  type        = string
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