# Metallb 설정
kubespray로 metallb 설치를 위해 설정해줘야 할 변수 값을 몇개 있습니다.

- Enable ARP 모드:  
  파일: `inventory/tmaxcloud/group_vars/k8s_cluster/k8s-cluster.yml`
  ```yaml
  kube_proxy_strict_arp: true
  ```

- Enable Metallb addon:  
  파일: `inventory/tmaxcloud/group_vars/k8s_cluster/addons.yml`
  metallb_protocol에서 metalLB mode를 결정합니다
  ```yaml
  metallb_enabled: true
  metallb_speaker_enabled: '{{ metallb_enabled }}'
  metallb_version: v0.13.10
  metallb_protocol: "layer2"
  ```

- address_pools: metallb에서 사용할 대역 설정 (호스트와 동일한 대역 사용)
  ```yaml
  metallb_config:
  address_pools:
    pool1:
      auto_assign: true
      ip_range:
        - 10.6.0.0/16
    primary:
      auto_assign: true
      ip_range:
        - 10.96.0.0/16
  ```

# L2 mode 설정

- address_pool 선택: 
  ```yaml
  metallb_config:
    address_pools:
      primary:
        auto_assign: true
        ip_range:
          - 10.96.0.0/16
    layer2:
      - primary
  ```

- interface 선택: 
  ```yaml
  metallb_interfaces:
  - ens2f3
  ```

# L3 mode 설정
  ```yaml
  layer3:
    communities:
      NO_ADVERTISE: '65535:65282'
      vpn-only: '1234:1'
    defaults:
      hold_time: 120s
      peer_port: 179
    metallb_peers:
      peer1:
        address_pool:
          - pool1
        communities:
          - vpn-only
        my_asn: 4200000000
        peer_address: 10.6.0.1
        peer_asn: 64512
      peer2:
        address_pool:
          - pool2
        communities:
          - NO_ADVERTISE
        my_asn: 4200000000
        peer_address: 10.10.0.1
        peer_asn: 64513
  ```

