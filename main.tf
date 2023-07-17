# Provider configuration
provider "aws" {
  region = var.region
}

# Module for network resources
module "network" {
  source = "./network"
}

# EC2 Launch Configuration
resource "aws_launch_configuration" "cloudgen_config" {
  name_prefix                 = "cloudgen"
  image_id                    = var.ami_id
  instance_type               = var.instance_type
  security_groups             = [module.network.public_security_group_id]
  associate_public_ip_address = true
  key_name                    = data.aws_secretsmanager_secret.key_pair_secret.secret_string
}

# Auto Scaling Group
resource "aws_autoscaling_group" "cloudgen_asg" {
  name                 = "my_asg"
  launch_configuration = aws_launch_configuration.cloudgen_config.id
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2
  vpc_zone_identifier  = [module.network.public_subnet_id]
}

# Load Balancer
resource "aws_elb" "cloudgen_elb" {
  name            = "my-elb"
  security_groups = [module.network.public_security_group_id]
  subnets         = [module.network.public_subnet_id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 400
}

# RDS Instance
resource "aws_db_instance" "cloudgen_instance" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = var.db_instance_type
  identifier             = "my_db_instance"
  username               = data.aws_secretsmanager_secret.db_username_secret.secret_string
  password               = data.aws_secretsmanager_secret.db_password_secret.secret_string
  publicly_accessible    = false
  vpc_security_group_ids = [module.network.private_security_group_id]
  subnet_group_name      = "my_db_subnet_group"

  tags = {
    Name = "cloudgen_db_instance"
  }
}
