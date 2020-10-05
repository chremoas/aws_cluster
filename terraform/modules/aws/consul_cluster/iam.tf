resource "aws_iam_role_policy" "consul_autodiscovery" {
  policy = data.aws_iam_policy_document.consul_autodiscovery.json
  role = aws_iam_role.consul_autodiscovery.id
}

data "aws_iam_policy_document" "consul_autodiscovery" {
  statement {
    effect = "Allow"
    actions = ["ec2:DescribeInstance*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "consul_autodiscovery" {
  name = "${var.cluster_name}-autodiscovery"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Name = "${var.cluster_name}-autodiscovery"
    Application = "consul"
    Terraform = "true"
    Environment = "shared"
  }
}

resource "aws_iam_instance_profile" "consul_autodiscovery" {
  name = "${var.cluster_name}-autodiscovery"
  role = aws_iam_role.consul_autodiscovery.name
}
