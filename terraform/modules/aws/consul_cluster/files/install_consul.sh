#!/bin/bash -e
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

TMPFILE=$(mktemp)
PWD=$(pwd)
#CONSUL_VERSION="1.8.4"
#CONSUL_TEMPLATE_VERSION="0.25.1"

#Load Linux utils
until git clone https://github.com/aws-quickstart/quickstart-linux-utilities.git ; do echo "Retrying"; done
cd /quickstart-linux-utilities && source quickstart-cfn-tools.source
# Prep operating systems
qs_update-os || qs_err
qs_bootstrap_pip || qs_err
qs_aws-cfn-bootstrap || qs_err

declare -A ARCH_MAP
ARCH_MAP[x86_64]=amd64
ARCH_MAP[aarch64]=arm64

ARCH="$${ARCH_MAP[$(uname -p)]}"

curl --output "$${TMPFILE}" -q https://releases.hashicorp.com/consul/"${CONSUL_VERSION}"/consul_"${CONSUL_VERSION}"_linux_"$${ARCH}".zip
unzip -d /usr/bin "$${TMPFILE}"
rm "$${TMPFILE}"

curl --output "$${TMPFILE}" -q https://releases.hashicorp.com/consul-template/"${CONSUL_TEMPLATE_VERSION}"/consul-template_"${CONSUL_TEMPLATE_VERSION}"_linux_"$${ARCH}".zip
unzip -d /usr/bin "$${TMPFILE}"
rm "$${TMPFILE}"

myip=$(echo $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4))
sed -i "s/PrivateIpAddress/$${myip}/g" /opt/consul/config/server.hcl

myid=$(echo $(curl -s http://169.254.169.254/latest/meta-data/instance-id))
sed -i "s/InstanceId/$${myid}/g" /opt/consul/config/server.hcl

chown -R consul:consul /opt/consul
systemctl daemon-reload
systemctl enable consul
systemctl start consul
systemctl restart dnsmasq

