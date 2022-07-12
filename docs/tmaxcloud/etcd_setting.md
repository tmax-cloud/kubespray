# ETCD 설정 변경 


- command/--listen-metrics-urls에 master ip 추가하기

    etcd manifest 내 .spec.containers[0].command[]의 `--listen-metrics-urls`에 master ip 추가를 원한다면,   
    `roles/kubernetes/postinstall/defaults/main.yml`에서 `master_ip_in_listen_metrics_urls`을 `true`로 변경한다.

    ex)
    `roles/kubernetes/postinstall/defaults/main.yml`
    ```bash
    master_ip_in_listen_metrics_urls: true
    ```

    master node의 ip가 10.10.1.208인 경우, 생성된 etcd.yaml (`/etc/kubernetes/manifests/etcd.yaml`)
    ```bash
    - --listen-metrics-urls=http://127.0.0.1:2381,http://10.10.1.208:2381
    ```