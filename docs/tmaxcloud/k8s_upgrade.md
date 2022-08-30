# installer k8s version upgrade 가이드

#### 반드시 k8s가 구축된 환경에서 진행되어야 한다.
#### 하나의 MINOR 버전에서 다음 MINOR 버전으로, 또는 동일한 MINOR의 PATCH 버전 사이에서만 업그레이드할 수 있다.
#### ex) 1.15 버전에서 1.17 버전으로 한번에 업그레이드는 불가능 하다. 1.15 -> 1.16 -> 1.17 스텝을 진행 해야 한다.

#### k8s version을 upgrade 하기위해 upgrade-cluster.yml을 수행한다.
```yml
ansible-playbook -i {inventory.ini file path} --become --become-user=root upgrade-cluster.yml -e kube_version={k8s_version} -v

ex) ansible-playbook -i inventory/tmaxcloud/inventory.ini --become --become-user=root upgrade-cluster.yml -e kube_version=v1.22.2 -v
```

#### 예시

예를 들어 k8s v1.19.4 -> k8s v1.22.2 upgrade 진행 시에 아래와 같은 순서로 진행한다.

```yml
1) ansible-playbook -i inventory/tmaxcloud/inventory.ini --become --become-user=root upgrade-cluster.yml -e kube_version=v1.20.2 -v
    node 및 pod 정상화 확인

2) ansible-playbook -i inventory/tmaxcloud/inventory.ini --become --become-user=root upgrade-cluster.yml -e kube_version=v1.21.2 -v
    node 및 pod 정상화 확인
    
3) ansible-playbook -i inventory/tmaxcloud/inventory.ini --become --become-user=root upgrade-cluster.yml -e kube_version=v1.22.3 -v
    node 및 pod 정상화 확인
```
