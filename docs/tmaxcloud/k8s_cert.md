# K8S 인증서 기간 설정 변경 

k8s default 인증서 기간 설정을 원한다면 아래 경로에서 변수를 설정한다. 
- inventory/tmaxcloud/group_vars/k8s_cluster/k8s-cluster.yml 을 수정한다.
- update_cert가 true인 경우 cert_days에 설정한 기간으로 인증서 기간이 설정되며, false인 경우 k8s default 값인 1년이 설정된다.
- 변경되는 인증서들은 kubeadm으로 인증서 갱신되는 파일과 동일하다. (ex. kubeadm certs renew all)
- 인증서 적용시 /etc/kubernetes.old-$(date +%Y%m%d)와 같은 경로로 기존 /etc/kubernetes 파일들은 백업된다.

```yml
## k8s certs days
update_cert: true
cert_days: {change cert days}
```

인스톨러로 인증서 기간 갱신만 다시 하고 싶은 경우 아래와 같은 명령어를 수행한다.
```yml
ansible-playbook -i inventory/tmaxcloud/inventory.ini --become --become-user=root cluster.yml -v -t update-kubeadm-cert
```

수동으로 인증서 갱신이 필요한 경우 아래 링크를 참조하여 갱신한다.
```yml
https://github.com/tmax-cloud/install-k8s/blob/5.0/KUBE_CERTIFICATE_UPDATE_README.md
```

### 예시

예를 들어 아래와 같이 변수들의 값을 설정한다.

```yml
## k8s certs days
update_cert: true
cert_days: 3650
```
