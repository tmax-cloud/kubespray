variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key"
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Key"
}

variable "AWS_SSH_KEY_NAME" {
  description = "Name of the SSH keypair to use in AWS."
}

variable "AWS_DEFAULT_REGION" {
  description = "AWS Region"
}

//General Cluster Settings

variable "aws_cluster_name" {
  description = "Name of AWS Cluster"
}

data "aws_ami" "distro" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS 8.4.2105 x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["125523088429"] # Canonical
}

//AWS VPC Variables

variable "aws_vpc_cidr_block" {
  description = "CIDR Block for VPC"
}

variable "aws_cidr_subnets_private" {
  description = "CIDR Blocks for private subnets in Availability Zones"
  type        = list(string)
}

variable "aws_cidr_subnets_public" {
  description = "CIDR Blocks for public subnets in Availability Zones"
  type        = list(string)
}

//AWS EC2 Settings

variable "aws_bastion_size" {
  description = "EC2 Instance Size of Bastion Host"
}

variable "aws_bastion_num" {
  description = "Number of Bastion Nodes"
}

/*
* AWS EC2 Settings
* The number should be divisable by the number of used
* AWS Availability Zones without an remainder.
*/
variable "aws_kube_master_num" {
  description = "Number of Kubernetes Master Nodes"
}

variable "aws_kube_master_size" {
  description = "Instance size of Kube Master Nodes"
}

variable "aws_kube_master_disk_size" {
  description = "Disk size for Kubernetes Master Nodes (in GiB)"
}

variable "aws_etcd_num" {
  description = "Number of etcd Nodes"
}

variable "aws_etcd_size" {
  description = "Instance size of etcd Nodes"
}

variable "aws_etcd_disk_size" {
  description = "Disk size for etcd Nodes (in GiB)"
}

variable "aws_kube_worker_num" {
  description = "Number of Kubernetes Worker Nodes"
}

variable "aws_kube_worker_size" {
  description = "Instance size of Kubernetes Worker Nodes"
}

variable "aws_kube_worker_disk_size" {
  description = "Disk size for Kubernetes Worker Nodes (in GiB)"
}

/*
* EC2 Source/Dest Check
*
*/
variable "aws_src_dest_check" {
  description   = "Instance source/destination check of Kubernetes Cluster"
  type          = bool
  default	= true
}

/*
* AWS ELB Settings
*
*/
variable "aws_elb_api_port" {
  description = "Port for AWS ELB"
}

variable "k8s_secure_api_port" {
  description = "Secure Port of K8S API Server"
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
}

variable "inventory_file" {
  description = "Where to store the generated inventory file"
}

variable "aws_elb_api_internal" {
  description   = "AWS ELB Scheme Internet-facing/Internal"
  type          = bool
  default	= true
}

/*
* VPN Connection
*
*/
variable "vpn_connection_enable" {
  description = "Controls if VPN_Connection should be created"
  type          = bool
}

variable "customer_gateway_ip" {
  type        = string
  description = "The IP address of the gateway's Internet-routable external interface"
}

variable "local_cidr" {
  type        = string
  description = "The IPv4 CIDR on the customer gateway (on-premises) side of the VPN connection."
}

