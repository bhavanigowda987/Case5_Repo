variable "region" {
  default = "us-east-2"
}

variable "bucket_name" {
  default = "cs5-shared-bucket"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI"
  default     = "ami-04f167a56786e4b09"
}
