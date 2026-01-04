terraform {
  required_version = "= 1.2.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.31.0"
    }
  }

  backend "s3" {
    bucket = "chrislewis-tfstate"
    key    = "docker-minecraft"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

# TODO: Can make more use of this config file
locals {
  config = jsondecode(file("${path.module}/../servers/${var.server_name}/config.json"))
}

module "infrastructure" {
  source = "github.com/c-d-lewis/terraform-modules//ecs-fargate-service?ref=master"

  region              = "eu-west-2"
  service_name        = "dkr-mc-${var.server_name}"
  container_cpu       = 4096
  container_memory    = 8192
  port                = local.config.PORT
  vpc_id              = "vpc-b1f181d9"
  certificate_arn     = "arn:aws:acm:us-east-1:617929423658:certificate/a69e6906-579e-431d-9e4c-707877d325b7"
  route53_zone_id     = "Z05682866H59A0KFT8S"
  route53_domain_name = "chrislewis.me.uk"
  create_efs          = true
  health_check_port   = 80
  create_alb          = false
  create_nlb          = true
}

output "dns_address" {
  value = module.infrastructure.service_dns
}

output "ecr_name" {
  value = module.infrastructure.ecr_name
}

output "ecr_uri" {
  value = module.infrastructure.ecr_uri
}

variable "server_name" {
  description = "Name of the selected server config"
  type        = string
}
