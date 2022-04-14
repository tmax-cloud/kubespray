# Kube-controller-manager 설정 변경 

- command/--port=0 삭제 

    kube-controller-manager .spec.containers[0].command[]에 `--port=0` 삭제 필요시 
    `roles/kubernetes/postinstall/defaults/main.yml`에서 `controller_manager_port_0`을 false로 변경한다. 

    예시)
    
    `roles/kubernetes/postinstall/defaults/main.yml`
    ```bash
    controller_manager_port_0: false
    ```

