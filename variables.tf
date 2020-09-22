variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "bastion_instance_type" {
  type    = string
  default = "t4g.micro"
}

variable "ecs_arm_cluster_instance_type" {
  type    = string
  default = "t4g.micro"
}

//variable "db_table_name" {
//  type    = string
//  default = "terraform-learn"
//}
//
//variable "db_read_capacity" {
//  type    = number
//  default = 1
//}
//
//variable "db_write_capacity" {
//  type    = number
//  default = 1
//}
