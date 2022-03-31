# ETCD command 설정 변경 


- command/--listen-metrics-urls 변경

    etcd manifest 내 .spec.containers[0].command[] 에 `--listen-metrics-urls` 변경 필요시   
    `inventory/tmaxcloud/group_vars/k8s_cluster/k8s-cluster.yml`에서 `MAIN_MASTER_IP`에 원하는 IP를 추가한다. 

    ex)

    `inventory/tmaxcloud/group_vars/k8s_cluster/k8s-cluster.yml`
    ```bash
    # Main master IP that etcd use as command/listen-metrics-urls
    MAIN_MASTER_IP: ["127.0.0.1"]
    ```

    생성된 etcd.yaml manifest(`/etc/kubernetes/manifests/etcd.yaml`)
    ```bash
        - --listen-metrics-urls=http://127.0.0.1:2381
    ```


    <br/>
    
    복수개의 IP 추가가 필요하다면 다음과 같이 명시한다. 

    ex)
    `inventory/tmaxcloud/group_vars/k8s_cluster/k8s-cluster.yml`
    ```bash
    # Main master IP that etcd use as command/listen-metrics-urls
    MAIN_MASTER_IP: ["127.0.0.1", "172.22.5.2"]
    ```

    생성된 etcd.yaml manifest(`/etc/kubernetes/manifests/etcd.yaml`)
    ```bash
        - --listen-metrics-urls=http://127.0.0.1:2381,http://172.22.5.2:2381
    ```