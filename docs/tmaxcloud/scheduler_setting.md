# Kube-scheduler 설정 변경

- command/--port=0 삭제 

    kube-scheduler .spec.containers[0].command[]에 `--port=0` 삭제 필요시 
    `roles/kubernetes/postinstall/defaults/main.yml`에서 `scheduler_port_0`을 false로 변경한다. 

    `roles/kubernetes/postinstall/defaults/main.yml`
    ```bash
    scheduler_port_0: false
    ```