variable "region" {
  default = "us-west-1"
}

variable "bucket_name" {
  default = "case5-bucket"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI"
  default     = "ami-014e30c8a36252ae5"
}
