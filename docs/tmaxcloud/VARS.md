# installer 구축시 중요 변수 설정
## inventory/tmaxcloud/group_vars/all/all.yml
apiserver lb domain name, address, port 설정(필수), upstream dns 설정(필요시에만)
```yml
apiserver_loadbalancer_domain_name: {{ controlplainEndpoint_ip(vip) }}
loadbalancer_apiserver:
  address: {{ controlplainEndpoint_ip(vip) }}
  port: 6443

upstream_dns_servers:
  - {{ upstream_dns_ip }}
```
### 예시
예를 들어 아래와 같이 변수들의 값을 설정한다.
```yml
apiserver_loadbalancer_domain_name: "10.0.10.10"
loadbalancer_apiserver:
  address: 10.0.10.10
  port: 6443

[AWS 사용시]
apiserver_loadbalancer_domain_name: "kubernetes-nlb-supercloud-43e596a4155bc464.elb.ap-northeast-1.amazonaws.com"
loadbalancer_apiserver:
  port: 6443

upstream_dns_servers:
  - /etc/resolv.conf
```

## inventory/tmaxcloud/group_vars/all/offline.yml
online, offline 설정(필수), offline 환경 구성시 repo 및 image registry 설정(필요시에만)
```yml
[online 설치시 - 나머지 모두 주석처리]
is_this_offline: false

[offline 설치시]
is_this_offline: true
registry_host: {{ image_registry_address }}
files_repo: {{ webserver_repo_url }}
```
### 예시
예를 들어 아래와 같이 변수들의 값을 설정한다.
```yml
[online 설치시]
is_this_offline: false
#registry_host: "10.0.10.1:5000"
#files_repo: "http://10.0.10.1"

## Container Registry overrides
#kube_image_repo: "{{ registry_host }}/registry.k8s.io"
#gcr_image_repo: "{{ registry_host }}/gcr.io"
#docker_image_repo: "{{ registry_host }}/docker.io"
...

[offline 설치시]
is_this_offline: true
registry_host: "10.0.10.1:5000"
files_repo: "http://10.0.10.1"

## Container Registry overrides
kube_image_repo: "{{ registry_host }}/registry.k8s.io"
gcr_image_repo: "{{ registry_host }}/gcr.io"
docker_image_repo: "{{ registry_host }}/docker.io"
quay_image_repo: "{{ registry_host }}/quay.io"
mcr_image_repo: "{{ registry_host }}/mcr.microsoft.com"
nvcr_image_repo: "{{ registry_host }}/nvcr.io"
elastic_image_repo: "{{ registry_host }}/docker.elastic.co"
us_gcr_image_repo: "{{ registry_host }}/us.gcr.io"
grafana_image_repo: "{{ registry_host }}/grafana/grafana"
efk_fluentd_image_repo: "{{ registry_host }}/fluent"
mysql_image_repo: "{{ registry_host }}/mysql"
efk_busybox_image_repo: "{{ registry_host }}/busybox"
aws_image_repo: "{{ registry_host }}/public.ecr.aws"

## Kubernetes components
kubeadm_download_url: "{{ files_repo }}/kubeadm-{{ kubeadm_version }}-{{ image_arch }}"
kubectl_download_url: "{{ files_repo }}/kubectl-{{ kubeadm_version }}-{{ image_arch }}"
kubelet_download_url: "{{ files_repo }}/kubelet-{{ kubeadm_version }}-{{ image_arch }}"
...
```

## inventory/tmaxcloud/group_vars/k8s_cluster/k8s-cluster.yml
k8s_cluster 관련 설정(필수), metallb, oidc, audit 설정시(필요시에만)
```yml
kube_version: {{ k8s version }}
kube_network_plugin: {{ cni }}
kube_service_addresses: {{ service_pod_network_subnet/cidr }}
kube_pods_subnet: {{ pod_network_subnet/cidr }}
container_manager: {{ container runtime }}
```
### 예시
예를 들어 아래와 같이 변수들의 값을 설정한다.
```yml
kube_version: v1.25.0
kube_network_plugin: calico
kube_service_addresses: 10.96.0.0/16
kube_pods_subnet: 10.244.0.0/16
container_manager: crio

[MetalLB 설치시]
kube_proxy_strict_arp: true

[OIDC 설정시]
kube_oidc_auth: true
kube_oidc_url: https://hyperauth.{{ custom_domain_name }}/auth/realms/tmax
kube_oidc_client_id: hypercloud5
kube_oidc_username_claim: preferred_username
kube_oidc_username_prefix: '-'
kube_oidc_groups_claim: group

[aduit 설정시]
# audit log for kubernetes
kubernetes_audit: true
audit_policy_file: "{{ kube_config_dir }}/pki/audit-policy.yaml"

# audit webhook for kubernetes
kubernetes_audit_webhook: true
audit_webhook_config_file: "{{ kube_config_dir }}/pki/audit-webhook-config"
audit_webhook_mode: batch
```

## inventory/tmaxcloud/group_vars/k8s_cluster/addons.yml
default storage class 설정(필수), csi 설정(필수), metallb 설정(필요시에만)
```yml
default_storageclass_name: {{ default_storage_class }}

[NFS 설치시]
sc_name_0: nfs
sc_name_999: nfs

# nfs-external-provisioner
nfs_external_provisioner_enabled: true
nfs_namespace: nfs
nfs_server: {{ nfs_server_address }}
nfs_path: {{ nfs_path }}

[AWS EFS 설치시]
default_storageclass_name: efs-sc

sc_name_0: efs-sc-0
sc_name_999: efs-sc-999

# aws-efs-csi-driver
aws_efs_csi_enabled: true
aws_efs_csi_namespace: {{ efs_csi_namespace }}
aws_efs_csi_controller_replicas: {{ efs_csi_replicas }}
aws_efs_filesystem_id: {{ efs_filesystem_id }}

[MetalLB 설치시]
# MetalLB deployment
metallb_enabled: true
metallb_speaker_enabled: '{{ metallb_enabled }}'
metallb_version: v0.13.10
metallb_protocol: "layer2"
metallb_config:
  address_pools:
    primary:
      auto_assign: true
      ip_range:
        - 10.96.0.0/16
  layer2:
    - primary
metallb_limits_cpu: "100m"
metallb_limits_mem: "100Mi"

```
### 예시
예를 들어 아래와 같이 변수들의 값을 설정한다.
```yml
[NFS 설치시]
default_storageclass_name: nfs

sc_name_0: nfs
sc_name_999: nfs

# nfs-external-provisioner
nfs_external_provisioner_enabled: true
nfs_namespace: nfs
nfs_server: 10.0.10.10
nfs_path: /root/nfs

[AWS EFS 설치시]
default_storageclass_name: efs-sc

sc_name_0: efs-sc-0
sc_name_999: efs-sc-999

# aws-efs-csi-driver
aws_efs_csi_enabled: true
aws_efs_csi_namespace: aws-efs-csi
aws_efs_csi_filesystem_id: fs-0604545c24f7fe82d
aws_efs_csi_controller_replicas: 1

[MetalLB 설치시]
# MetalLB deployment
metallb_enabled: true
metallb_speaker_enabled: true
metallb_ip_range:
    - "172.22.8.160-172.22.8.180"
    - "172.22.8.184-172.22.8.190"
metallb_version: v0.9.3
metallb_protocol: "layer2"
```

## inventory/tmaxcloud/group_vars/k8s_cluster/k8s-net-calico.yml
calico 설정(필수)
```yml
calico_ip_auto_method: {{ cidr=HOST-POD-NETWORK-SUBNET/CIDR }}

[AWS 사용시 - zone별로 지정]
calico_ip_auto_method: {{ cidr=HOST-POD-NETWORK-SUBNET/CIDR }}, {{ cidr=HOST-POD-NETWORK-SUBNET/CIDR }}, {{ cidr=HOST-POD-NETWORK-SUBNET/CIDR }}
calico_ipip_mode: 'Always'
```
### 예시
예를 들어 아래와 같이 변수들의 값을 설정한다.
```yml
calico_ip_auto_method: "cidr=10.0.10.0/24"

[AWS 사용시 - zone별로 지정]
calico_ip_auto_method: "cidr=10.0.1.0/24, 10.0.3.0/24, 10.0.5.0/24"
calico_ipip_mode: 'Always'
```