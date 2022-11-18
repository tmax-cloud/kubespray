# installer k8s version upgrade 가이드

## 구성 요소 및 버전
* kubeadm (v1.19.4, v1.20.15, v1.21.14)
* kubelet (v1.19.4, v1.20.15, v1.21.14)
* kubectl (v1.19.4, v1.20.15, v1.21.14)

## Prerequisites
#### 1. 반드시 k8s가 구축된 환경에서 진행되어야 한다.
#### 2. 하나의 MINOR 버전에서 다음 MINOR 버전으로, 또는 동일한 MINOR의 PATCH 버전 사이에서만 업그레이드할 수 있다.
##### ex) 1.19 버전에서 1.21 버전으로 한번에 업그레이드는 불가능 하다. 1.19 -> 1.20 -> 1.21 스텝을 진행 해야 한다.

#### 3. upgrade시 node drain 관련 사전 체크를 한다.
##### 업그레이드 진행시 해당 노드에 있는 pod가 다른 노드로 재스캐줄링 된다.
##### 이때 PDB가 존재하는 Pod가 drain하려는 node에 생성되어있는 경우 evict가 제한 되기 때문에, 아래 명령어로 drain이 가능한 상태인지 먼저 확인한다.
```bash
kubectl get pdb -A
or
kubectl get pdb <pdb-name> -oyaml
```

##### ALLOWED DISRUPTIONS 및 drain 시키려는 node의 pod 상태를 확인한다.
###### PDB의 ALLOWED DISRUPTIONS가 drain을 시도하는 node에 뜬 pod(pdb 설정 pod) 개수보다 적을 경우 아래와 같이 다른 노드로 재스케줄링이 필요하다.
###### ex) virt-api pod가 drain하려는 node에 2개 떠있는데, ALLOWED DISRUPTIONS는 0 또는 1일 경우 
###### 해당 조건에 만족하지 않는 경우 'Cannot evict pod as it would violate the pod's disruption budget' 와 같은 에러가 발생할 수 있다.
###### warning: node drain시 해당 node상의 pod가 evict되기 때문에, pod의 local-data의 경우 보존되지 않는다.

##### 4. 해결 방법       
1) 해당 Pod를 다른 Node로 재스케줄링을 시도한다.
 ```bash
kubectl delete pod <pod-name>
```
2) 다른 Node의 리소스 부족, noScheduling 설정 등으로 인해 a번 재스케줄링이 불가할 경우엔 PDB 데이터를 삭제하고 업그레이드 진행 후에 PDB 데이터를 복구한다.
```bash
kubectl get pdb <pdb-name> -o yaml > pdb-backup.yaml

kubectl apply -f pdb-backup.yaml
```

## 온라인 구축 가이드
#### k8s version을 upgrade 하기위해 upgrade-cluster.yml을 수행한다.
```yml
ansible-playbook -i {inventory.ini file path} --become --become-user=root upgrade-cluster.yml -e kube_version={k8s_version} -v

ex) ansible-playbook -i inventory/tmaxcloud/inventory.ini --become --become-user=root upgrade-cluster.yml -e kube_version=v1.20.15 -v
ex) ansible-playbook -i inventory/tmaxcloud/inventory.ini --become --become-user=root upgrade-cluster.yml -e kube_version=v1.21.14 -v
```

#### 예시
예를 들어 k8s v1.19.4 -> k8s v1.21.14 upgrade 진행 시에 아래와 같은 순서로 진행한다.
```yml
1) ansible-playbook -i inventory/tmaxcloud/inventory.ini --become --become-user=root upgrade-cluster.yml -e kube_version=v1.20.15 -v
    node 및 pod 정상화 확인
    
2) ansible-playbook -i inventory/tmaxcloud/inventory.ini --become --become-user=root upgrade-cluster.yml -e kube_version=v1.21.14 -v
    node 및 pod 정상화 확인
```

## 온프라인 구축 가이드
#### 1. image registry를 구축한다.
  * podman을 설치 후 /etc/containers/registries.conf에 insecure registry 등록한다.
    ```bash
    yum install podman
    
    [registires.insecure]
    registries = ['<내부망IP>:<PORT>']
    ex) registries = ['10.0.10.50:5000']
    ```
  * 아래의 ftp에서 supercloud-images.tar와 registry.tar를 다운로드 한다.
    * ftp : 192.168.1.150:/home/ck-ftp/k8s/install/offline/supercloud-images
  * registry.tar를 load 한다.
    ```bash
    $ podman load -i registry.tar
    ```    
  * 다운로드 한 tar 압축을 풀고 해당 host path로 image registry를 띄운다.
    ```bash
    $ tar -xvf supercloud-images.tar
    $ podman run -it -d -p{image registry ip:port}:5000 --privileged -v {image tar 푼 경로}:/var/lib/registry registry
    EX) podman run -it -d -p10.0.10.50:5000:5000 --privileged -v /root/supercloud-registry:/var/lib/registry registry
    ```
* 비고 :
    * 위 내용은 1개의 node에서만 구축 진행한다.
    * aws같은 다른 provider에 sub cluster 구축시에는 on-premise node에 구축 가능하다.

#### 2. webserver repo를 구축한다.
  * files-repo에는 pre-required packages들은 반드시 포함되어있어야 한다.
  
  * 아래의 ftp에서 files-repo를 다운로드 한다.
    * ftp : 192.168.1.150:/home/ck-ftp/k8s/install/offline/files-repo
  
  * 다운받은 files-repo로 web server repo를 구축할 node에 local repo를 구축한다.
    ```bash
    $ pushd {files-repo-path}
    $ createrepo_c ./
    $ modifyrepo_c modules.yaml ./repodata
    $ export LOCAL_REPO_PATH={files-repo-path}
    $ popd
    
    $ dnf config-manager --add-repo file://${LOCAL_REPO_PATH}
    ```
    * createrepo_c 명령어가 없는 경우, createrepo 명령어를 사용한다.
    * 추가적인 repo 구축 가이드는 아래 url을 참조한다.
      * https://github.com/tmax-cloud/install-pkg-repo/tree/5.0
    * dnf 명령어가 없는 경우, files-repo.repo를 생성한다.
      * vi /etc/yum.repos.d/files-repo.repo
      ```bash
      [files-repo]
      name=files-repo
      baseurl=file:///home/centos/files-repo
      enabled=0
      ```       
  * httpd를 다운로드 후, httpd.conf 내용을 수정한다.
    ```bash
    $ yum install httpd -y
    $ vi /etc/httpd/conf/httpd.conf
    
    ServerName {webserver-repo-ip}
    ex) ServerName 172.22.5.2
    
    <Directory />
       AllowOverride All
       Require all granted
       Order deny,allow
    </Directory>

    DocumentRoot "{files-repo-path}"
    ex) DocumentRoot "/home/centos/files-repo"

    <Directory "{files-repo-path}">
       AllowOverride None
       Require all granted
    </Directory>
    ```
  * httpd를 다운로드 후, 아래 해당되는 변수를 찾아서 httpd.conf 내용을 수정한다.
  * files-repo 권한 설정을 한다.
    ```bash
    $ chcon -R -t httpd_user_content_t {files-repo-path} 
    ex) chcon -R -t httpd_user_content_t /home/centos/files_repo
    
    $ chmod 711 {files-repo-path}
    ex) chmod 711 /home/centos/files_repo    
    ```   
  * httpd를 재시작 한다.
    ```bash
    $ systemctl restart httpd
    ```
  * kubespray로 설치할 모든 노드(master, worker)에는 구축한 repo를 바라볼수 있도록 설정한다.
    * vi /etc/yum.repos.d/files-repo.repo
    ```bash
    [files_repo]
    name=files repo
    baseurl=http://172.22.5.2/
    enabled=1
    gpgcheck=0
    ```  

#### 3. offline.yml을 수행한다.
  * offline 환경에서의 kubespray 설치를 위해 inventory/tmaxcloud/group_vars/all/offline.yml 을 수정한다.
    ```yml
    is_this_offline: true
    registry_host: private registry 주소
    files_repo: 구축한 webserver repo 경로
    ```
    
#### 예시
  * 예를 들어 아래와 같이 변수들의 값을 설정한다.
    ```yml
    is_this_offline: true
    registry_host: "10.0.10.50:5000"
    files_repo: "http://172.22.5.2"
    ```

#### 4. k8s version을 upgrade 하기위해 upgrade-cluster.yml을 수행한다.
```yml
ansible-playbook -i {inventory.ini file path} --become --become-user=root upgrade-cluster.yml -e kube_version={k8s_version} -v

ex) ansible-playbook -i inventory/tmaxcloud/inventory.ini --become --become-user=root upgrade-cluster.yml -e kube_version=v1.20.15 -v
ex) ansible-playbook -i inventory/tmaxcloud/inventory.ini --become --become-user=root upgrade-cluster.yml -e kube_version=v1.21.14 -v
```

#### 예시
예를 들어 k8s v1.19.4 -> k8s v1.21.14 upgrade 진행 시에 아래와 같은 순서로 진행한다.
```yml
1) ansible-playbook -i inventory/tmaxcloud/inventory.ini --become --become-user=root upgrade-cluster.yml -e kube_version=v1.20.15 -v
    node 및 pod 정상화 확인
    
2) ansible-playbook -i inventory/tmaxcloud/inventory.ini --become --become-user=root upgrade-cluster.yml -e kube_version=v1.21.14 -v
    node 및 pod 정상화 확인
```
