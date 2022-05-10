# storageclass

kubespray로 storageclass 설정 위해 inventory/tmaxcloud/group_vars/k8s_cluster/addons.yml에서 설정해야 하는 값은 다음과 같습니다.

```yml
postgresql_sc_name: postgresql을 배포하기 위해 필요한 pvc가 사용해야 하는 storageclass의 이름
```

### 예시

예를 들어 아래와 같이 변수들의 값을 설정합니다.

- nfs를 사용하는 환경에서는 무조건 `nfs`로 설정해야 합니다.

```yml
postgresql_sc_name: efs-sc-postgresql
```
