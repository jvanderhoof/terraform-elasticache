/**************************************************************************

# Overview:
  This module is an abstraction of the subnet group and security group required to provision and restrict access to elasticache clusters (redis & memcached)

Inputs:
  Required:
    cluster_name - name of cluster.  Should contain only lower case letters and '-'
    security_group_ids - comma seperated list of security group ids which are allowed to access this Elasticache cluster
    subnet_ids - comma seperated list of subnet ids available to this Elasticache cluster
    vpc_id - VPC id for this Elasticache cluster
    port - port to run on

Outputs:
  subnet_group_name - name of the subnet group created
  security_group_id - security group id created


**************************************************************************/

#
# Module Inputs
#
variable "cluster_name" {}
variable "subnet_ids" {}
variable "vpc_id" {}
variable "port" {}
variable "security_group_ids" {}

#
# Setup
#
resource "aws_elasticache_subnet_group" "elasticache-subnet-group" {
  name = "${var.cluster_name}-elasticache-subnet-group"
  description = "${var.cluster_name} elasticache subnet group"
  subnet_ids = ["${split(",", "${var.subnet_ids}")}"]
}

resource "aws_security_group" "elasticache-traffic" {
  name = "${var.cluster_name}-traffic"
  vpc_id = "${var.vpc_id}"
  description = "elasticache cluster security group"
  ingress {
    from_port = "${var.port}"
    to_port = "${var.port}"
    protocol = "tcp"
    security_groups = ["${split(",", "${var.security_group_ids}")}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#
# Module Outputs
#
output "subnet_group_name" {
  value = "${aws_elasticache_subnet_group.elasticache-subnet-group.name}"
}

output "security_group_id" {
  value = "${aws_security_group.elasticache-traffic.id}"
}
