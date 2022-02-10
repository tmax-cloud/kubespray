# Bootstrap HyperCloud

## 1. Private registry에서 HyperRegistry로 이미지 복제하기

roles/bootstrap-cloud/files/dup.sh을 이용

```
dup.sh <source_registry> <target_harbor_domain>
# ex) dup.sh 10.0.10.50:5000 hyperregistry.shinhan.com
```

## 2. argoCD로 모듈 설치 후 hyperauth와 oidc 연동

- 기존의 OIDC 연동 가이드 [참조](https://github.com/tmax-cloud/HyperRegistry-Chart/blob/5.0/docs/oidc.md)


## 3. Traefik ingress로 업데이트

1. 복사된 values.yaml(혹은 hr-nginx-values.yml)에서 다음을 참조하여 수정
    ```yaml
    expose:
      type: ingress
      tls:
        enabled: true
        certSource: none
      ingress:
        class: "tmax-cloud"
      hosts:
        core: hyperregistry.{{ custom_domain_name }}
        notary: hyperregistry-notary.{{ custom_domain_name }}
      controller: default
      labels:
        ingress.tmaxcloud.org/name: hyperregistry
      annotations:
        ingress.kubernetes.io/ssl-redirect: "true"
        ingress.kubernetes.io/proxy-body-size: "0"
        traefik.ingress.kubernetes.io/router.entrypoints: websecure
    ...
    externalURL: https://hyperregistry.{{ custom_domain_name }}
    ...
    ```
    |참고| values.yaml 위치는 마스터노드 /etc/kubernetes/addons/hyperregistry/ 경로상에 존재   

2. 설치된 릴리즈 업그레이드
    ```bash
    helm upgrade <release_name> hr/HyperRegistry -f values.yml
    ```
