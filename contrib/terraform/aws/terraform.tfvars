#Global Vars
aws_cluster_name = "devtest"

#VPC Vars
aws_vpc_cidr_block       = "10.250.192.0/18"
aws_cidr_subnets_private = ["10.250.192.0/20", "10.250.208.0/20"]
aws_cidr_subnets_public  = ["10.250.224.0/20", "10.250.240.0/20"]

#Bastion Host
aws_bastion_size = "t2.medium"


#Kubernetes Cluster

aws_kube_master_num  = 3
aws_kube_master_size = "t2.medium"

aws_etcd_num  = 3
aws_etcd_size = "t2.medium"

aws_kube_worker_num  = 4
aws_kube_worker_size = "t2.medium"

#EC2 Source/Dest Check
aws_src_dest_check      = false

#Settings AWS ELB

aws_elb_api_port                = 6443
k8s_secure_api_port             = 6443
kube_insecure_apiserver_address = "0.0.0.0"

default_tags = {
  #  Env = "devtest"
  #  Product = "kubernetes"
}

#Setting VPN Connection

vpn_connection_enable = true
customer_gateway_ip   = "175.195.163.19"
local_cidr            = "172.23.3.0/24"

inventory_file = "../../../inventory/hosts"
