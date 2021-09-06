## 구성 요소 및 버전
* nss - 3.53.1-17.el8_3
* conntrack - 1.4.4-10.el8
* socat - 1.7.3.3-2.el8
* python3-pip-python 3.6
* python3-cryptography-3.2.1-4.el8 (BaseOS)
* python3-jinja2- 2.10.1-2.el8_0 (AppStream)
* python3-netaddr-0.7.19-8.el8 (AppStream)
* python3-jmespath-0.9.0-11.el8 (AppStream)
* python3-ruamel-yaml-0.15.41-2.el8 (epel)
* python3-pbr-5.1.2-3.el8 (epel-release)
* ansible - 2.9.23-1.el8 (epel)
* cri-o-1.19 - cri-o-1.19.1-12.1.el8.x86_64.rpm
* calico-3.17.4.tar.gz
* cni-plugins-linux-amd64-v0.9.1.tgz
* calicoctl-linux-amd64
* dnstools.tar.gz
* nfs-utils-1:2.3.3-41.el8_4.2.x86_64
* java-1.8.0-openjdk-devel.x86_64
* community.crypto
* community.kubernetes 

## Prerequisites
* 클러스터 구성전 master, worker node 최소 스팩
  * master node (controll plane node) - CPU : 2Core 이상
  * master/worker node - RAM : 2GiB 이상

## 폐쇄망 구축 가이드 
1. 아래 가이드를 참고 하여 image registry를 구축한다.
  * podman을 설치 후 /etc/containers/registries.conf에 insecure registry 등록한다.
    ```bash
    [registires.insecure]
    registries = ['<내부망IP>:<PORT>']
    ex) registries = ['10.0.10.50:5000']
    ```
  * supercloud-images.tar를 다운로드 후 tar 압축을 풀고 해당 host path로 image registry를 띄운다.
    ```bash
    $ tar -xvf registry.tar
    $ podman run -it -d -p{ image registry ip:port }:5000 --privileged -v { image tar 푼 경로 }:/var/lib/registry registry
    EX) podman run -it -d -p10.0.10.50:5000:5000 --privileged -v /root/supercloud-registry:/var/lib/registry registry
    ```
* 비고 :
    * 위 내용은 1개의 node에서만 진행한다.

2. 아래 가이드를 참고 하여 file repo를 구축한다.
  * file repo에서 사용할 하위 파일들을 kubespray 실행 노드 특정 디렉토리(ex. /tmp/files-repo)에 배치 준비한다.
    ```bash
    $ mkdir /tmp/files-repo

    https://storage.googleapis.com/kubernetes-release/release/v1.19.4/bin/linux/amd64/kubeadm
    https://storage.googleapis.com/kubernetes-release/release/v1.19.4/bin/linux/amd64/kubectl
    https://storage.googleapis.com/kubernetes-release/release/v1.19.4/bin/linux/amd64/kubelet
    https://github.com/containernetworking/plugins/releases/download/v0.9.1/cni-plugins-linux-amd64-v0.9.1.tgz
    https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.19.0/crictl-v1.19.0-linux-amd64.tar.gz
    https://github.com/projectcalico/calicoctl/releases/download/v3.17.4/calicoctl-linux-amd64
    https://github.com/projectcalico/calico/archive/calico-v3.17.4.tar.gz
    https://github.com/etcd-io/etcd/releases/download/v3.4.13/etcd-v3.4.13-linux-amd64.tar.gz
    https://tmax-cloud.github.io/HyperRegistry-Chart/hyperregistry-v2.2.2.tgz
    https://get.helm.sh/helm-v3.5.4-linux-amd64.tar.gz
    
    ```
* 비고 :
    * 특정 디렉토리 변경시에는 kubespray/inventory/tmaxcloud/group_vars/all/offline.yml 의 "files_repo" 부분을 경로에 맞게 수정한다.


3. 아래 가이드를 참고 하여 kubespray 설치를 위한 환경설정을 한다.
  * (kubespray install playbook 실행 하는 노드) sshpass 설치 및 ssh key 배포 한다.
    ```bash
    $ yum -y install sshpass
    $ ssh-keygen -t rsa
    $ ssh-copy-id -i root@<설치할모든노드IP>

    테스트 : ssh 접근이 비밀번호 없이 가능
    ```
  * (모든 노드) resolv.conf 파일 확인 한다.
    * 구축할 모든 노드에 /etc/resolv.conf 파일이 있는지 확인, 없으면 생성  

4. kubespray로 설치할 준비를 한다.
  * (kubespray install playbook 실행 하는 노드) kubespray를 다운로드 한다.
    ```bash
    $ git clone https://github.com/tmax-cloud/kubespray.git
    $ cd kubespray
    $ git checkout tmax-master
    ```
  * (kubespray install playbook 실행 하는 노드) kubespray 의존성 패키지 설치 한다.
    ```bash
    $ yum -y install python3-pip python3-cryptography python3-jinja2 python3-netaddr python3-jmespath python3-ruamel-yaml python3-pbr ansible
    $ ansible-galaxy collection install community.crypto 
    $ ansible-galaxy collection install community.kubernetes 
    ```
    
5. kubespray에서 사용할 사용자 변수들을 설정한다.
  * https://github.com/tmax-cloud/kubespray/tree/tmax-master/docs/tmaxcloud 에 있는 md를 참고하여 설정한다.