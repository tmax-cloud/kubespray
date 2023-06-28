function (
  timezone="UTC",
  is_offline="false",
  private_registry="172.22.6.2:5000",
  loki_image_tag="2.7.1",
  loki_volume_size="50Gi",
  promtail_image_tag="2.7.1",
  custom_clusterissuer="tmaxcloud-issuer",
  is_master_cluster="true",
  log_level="info",
  storage_class="default"
)

[
  {
    "apiVersion": "v1",
    "kind": "ConfigMap",
    "metadata": {
      "name": "loki-config",
      "namespace": "monitoring",
    },
    "data": {
      "loki.yaml": std.join("\n", 
        [
          "auth_enabled: false",
          "ingester:",
          "  chunk_idle_period: 5m",
          "  max_chunk_age: 1h",
          "  chunk_retain_period: 30s",
          "  max_transfer_retries: 0",
          "  wal:",
          "    enabled: false",
          "  lifecycler:",
          "    address: 0.0.0.0",
          "    ring:",
          "      replication_factor: 1",
          "      kvstore:",
          "        store: inmemory",
          "    final_sleep: 0s",
          "querier:",
          "  max_concurrent: 2048",
          "  query_ingesters_within: 0",
          "  query_timeout: 5m",
          "query_scheduler:",
          "  max_outstanding_requests_per_tenant: 2048",
          "limits_config:",
          "  retention_period: 168h",
          "  enforce_metric_name: false",
          "  ingestion_rate_mb: 16",
          "  ingestion_burst_size_mb: 32",
          "  max_query_series: 100000",
          "  per_stream_rate_limit: 512mb",
          "  per_stream_rate_limit_burst: 1024mb",
          "schema_config:",
          "  configs:",
          "  - from: 2022-07-10",
          "    store: boltdb-shipper",
          "    object_store: filesystem",
          "    schema: v11",
          "    index:",
          "      prefix: index_",
          "      period: 24h",
          "server:",
          "  http_listen_port: 3100",
          std.join("", ["  log_level: ", log_level]),
          "  http_server_read_timeout: 5m",
          "  http_server_write_timeout: 5m",
          "storage_config:",
          "  boltdb_shipper:",
          "    active_index_directory: /loki/index",
          "    cache_location: /loki/index_cache",
          "    cache_ttl: 24h",
          "    shared_store: filesystem",
          "  filesystem:",
          "    directory: /loki/chunks",
          "chunk_store_config:",
          "  max_look_back_period: 168h",
          "compactor:",
          "  retention_enabled: true",
          "  retention_delete_delay: 30m",
          "  working_directory: /loki/compactor",
          "  shared_store: filesystem",
          "ruler:",
          "  storage:",
          "    type: local",
          "    local:",
          "      directory: /loki/rules",
          "  rule_path: /loki/scratch",
          "  alertmanager_url: http://alertmanager-main.monitoring.svc:9063",
          "  wal:",
          "    dir: /loki/wal",
          "  ring:",
          "    kvstore:",
          "      store: inmemory",
          "  enable_api: true",
          "  enable_alertmanager_v2: true"
        ]
      )
    }
  }
]