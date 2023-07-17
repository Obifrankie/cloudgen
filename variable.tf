variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID"
  default     = "ami-12345678"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_pair" {
  description = "Key pair name"
  default     = "my_key_pair"
}

variable "db_instance_type" {
  description = "RDS instance type"
  default     = "db.t2.micro"
}

variable "db_username" {
  description = "RDS username"
  default     = "admin"
}

variable "db_password" {
  description = "RDS password"
  default     = "password"
}

