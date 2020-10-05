variable "architecture" {
  type = string
  validation {
    condition = var.architecture == "amd64" || var.architecture == "arm64"
    error_message = "Valid architectures are \"amd64\" and \"arm64\"."
  }
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "ssh_key_name" {
  type = string
}

variable "instance_type" {
  type = string
  default = "t4g.nano"
}

variable "servers" {
  type = number
  default = 3
  validation {
    condition = var.servers == 3 || var.servers == 5 || var.servers == 7
    error_message = "Valid options are 3, 5 or 7."
  }
}

variable "aws_region" {
  type = string
}

variable "cluster_name" {
  type = string
  default = "consul-cluster"
}

variable "ssh_allowed_cidrs" {
  type = list(string)
  default = []
}

variable "consul_allowed_cidrs" {
  type = list(string)
  default = []
}

variable "consul_version" {
  type = string
}

variable "consul_template_version" {
  type = string
}

variable "leave_on_terminate" {
  type = bool
  default = true
}