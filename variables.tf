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

// Below is consul added stuff

variable "alb_log_bucket" {
  description = "s3 bucket to send ALB Logs"
  default = "consul-4amlunch"
}

variable "lb_logs_enabled" {
  default = "true"
}

variable "lb_deregistration_delay" {
  description = "The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds. The default value is 300 seconds."
  default     = "300"
}

variable "cloudwatch_log_retention" {
  default     = "30"
  description = "Specifies the number of days you want to retain log events in the specified log group. (defaults to 30)"
}

variable "cluster_size" {
  default     = "3"
  description = "Consul cluster size. This must be greater than 3"
}

variable "consul_image" {
  description = "Image to use when deploying consul, defaults to the hashicorp consul image"
  default     = "consul:latest"
}

variable "consul_memory_reservation" {
  description = "The soft limit (in MiB) of memory to reserve for the container, defaults 32"
  default     = "32"
}

variable "datacenter_name" {
  description = "Optional override for datacenter name"
  default     = ""
}

variable "definitions" {
  type        = list(string)
  description = "List of Consul Service and Health Check Definitions"
  default     = ["ecs-cluster"]
}

variable "dns_zone" {
  description = "Zone where the Consul UI alb will be created. This should *not* be consul.example.com.  Uses the default AWS domain name if not set."
  default     = ""
}

//variable "ecs_cluster_ids" {
//  type        = list(string)
//  description = "List of ARNs of the ECS Cluster IDs"
//}

variable "env" {
  default = "prod"
}

variable "enable_script_checks" {
  description = "This controls whether health checks that execute scripts are enabled on this agent, and defaults to false"
  default     = false
}

variable "hostname" {
  description = "DNS Hostname for the bastion host. Defaults to $${VPC NAME}.$${dns_zone} if hostname is not set"
  default     = ""
}

variable "sidecar_image" {
  default     = "fitnesskeeper/consul-sidecar"
  description = "Image to use when deploying health check agent, defaults to fitnesskeeper/consul-sidecar:latest image"
}

variable "sidecar_memory_reservation" {
  description = "The soft limit (in MiB) of memory to reserve for the container, defaults 32"
  default     = "32"
}

variable "join_ec2_tag_key" {
  description = "EC2 Tag Key which consul uses to search to generate a list of IP's to Join. Defaults to Name"
  default     = "Name"
}

variable "join_ec2_tag" {
  description = "EC2 Tags which consul will search for in order to generate a list of IP's to join. See https://github.com/hashicorp/consul-ec2-auto-join-example for more examples."
  default = "chremoas-consul"
}

variable "iam_path" {
  default     = "/"
  description = "IAM path, this is useful when creating resources with the same name across multiple regions. Defaults to /"
}

variable "s3_backup_bucket" {
  description = "S3 Bucket to use to store backups of consul snapshots"
  default = "consul-4amlunch"
}

//variable "subnets" {
//  type        = list(string)
//  description = "List of subnets used to deploy the Consul alb"
//}

variable "raft_multiplier" {
  description = "An integer multiplier used by Consul servers to scale key Raft timing parameters https://www.consul.io/docs/guides/performance.html"
  default     = "5"
}

variable "region" {
  default     = "us-east-1"
  description = "AWS Region, defaults to us-east-1"
}

variable "registrator_image" {
  default     = "gliderlabs/registrator:latest"
  description = "Image to use when deploying registrator agent, defaults to the gliderlabs registrator:latest image"
}

variable "registrator_memory_reservation" {
  description = "The soft limit (in MiB) of memory to reserve for the container, defaults 32"
  default     = "32"
}

# The below var is pretty much useless until we stop doing the multiple of two thing with number of desired tasks
variable "service_minimum_healthy_percent" {
  description = "The minimum healthy percent represents a lower limit on the number of your service's tasks that must remain in the RUNNING state during a deployment (default 66)"
  default     = "66"
}

variable "leave_on_terminate" {
  description = "If enabled, when the agent receives a TERM signal, it will send a Leave message to the rest of the cluster and gracefully leave. Defaults to true in this module so that containers will gracefully leave the consul cluster when ECS stops the task."
  default     = true
}

variable "sha_htpasswd_hash" {
  description = "Entries must be created with htpasswd -s for SHA encryption"
  default = "{SHA}AP8mKXbjJVeVDDm9EGEXb7HPoC4="
}

variable "oauth2_proxy_htpasswd_file" {
  description = "Path the htpasswd file"
  default     = "/conf/htpasswd"
}

variable "oauth2_proxy_provider" {
  description = "OAuth provider"
  default     = "github"
}

variable "oauth2_proxy_github_org" {
  description = "Github Org"
  default = "chremoas"
}

variable "oauth2_proxy_github_team" {
  description = "list of teams that should have access defaults to empty list (allow all)"
  type        = list(string)
  default     = []
}

variable "oauth2_proxy_client_id" {
  description = "the OAuth Client ID: ie: 123456.apps.googleusercontent.com"
  default = "be042c8230f87cae0878"
}

variable "oauth2_proxy_client_secret" {
  description = "the OAuth Client Secret"
  default = "693f5c777305f42e41ea41eb192adf9bcc44711a"
}
