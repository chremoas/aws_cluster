#!/bin/bash -e

CONSUL_CONFIG="/opt/consul/config/server.hcl"

myip=$(echo $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4))
sed -i "s/PrivateIpAddress/$${myip}/g" $${CONSUL_CONFIG}

myid=$(echo $(curl -s http://169.254.169.254/latest/meta-data/instance-id))
sed -i "s/InstanceId/$${myid}/g" $${CONSUL_CONFIG}

sed -i "s/DATACENTER/${datacenter}/g" $${CONSUL_CONFIG}
sed -i "s/LEAVE_ON_TERMINATE/${leave_on_terminate}/g" $${CONSUL_CONFIG}
sed -i "s/BOOTSTRAP_EXPECT/${bootstrap_expect}/g" $${CONSUL_CONFIG}
sed -i "s/AWS_REGION/${aws_region}/g" $${CONSUL_CONFIG}
sed -i "s/JOIN_EC2_TAG_KEY/${join_ec2_tag_key}/g" $${CONSUL_CONFIG}
sed -i "s/JOIN_EC2_TAG/${join_ec2_tag}/g" $${CONSUL_CONFIG}

systemctl enable consul-server
systemctl start consul-server

