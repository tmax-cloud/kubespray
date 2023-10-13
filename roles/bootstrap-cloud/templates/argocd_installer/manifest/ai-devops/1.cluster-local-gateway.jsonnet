function (    
    is_offline="false",
    private_registry="172.22.6.2:5000",    
    custom_domain_name="tmaxcloud.org",    
    tmax_client_secret="tmax_client_secret",
    hyperauth_url="172.23.4.105",
    hyperauth_realm="tmax",
    console_subdomain="console",    
    gatekeeper_log_level="info",    
    gatekeeper_version="v1.0.2",
    log_level="info",
    time_zone="UTC"
)

local target_registry = if is_offline == "false" then "" else private_registry + "/";

[    
    {
  "apiVersion": "apps/v1",
  "kind": "Deployment",
  "metadata": {
    "labels": {
      "app": "cluster-local-gateway",
      "install.operator.istio.io/owning-resource": "unknown",
      "istio": "cluster-local-gateway",
      "istio.io/rev": "default",
      "operator.istio.io/component": "IngressGateways",
      "release": "istio"
    },
    "name": "cluster-local-gateway",
    "namespace": "istio-system"
  },
  "spec": {
    "selector": {
      "matchLabels": {
        "app": "cluster-local-gateway",
        "istio": "cluster-local-gateway"
      }
    },
    "strategy": {
      "rollingUpdate": {
        "maxSurge": "100%",
        "maxUnavailable": "25%"
      }
    },
    "template": {
      "metadata": {
        "annotations": {
          "prometheus.io/path": "/stats/prometheus",
          "prometheus.io/port": "15020",
          "prometheus.io/scrape": "true",
          "sidecar.istio.io/inject": "false"
        },
        "labels": {
          "app": "cluster-local-gateway",
          "chart": "gateways",
          "heritage": "Tiller",
          "install.operator.istio.io/owning-resource": "unknown",
          "istio": "cluster-local-gateway",
          "istio.io/rev": "default",
          "operator.istio.io/component": "IngressGateways",
          "release": "istio",
          "service.istio.io/canonical-name": "cluster-local-gateway",
          "service.istio.io/canonical-revision": "latest",
          "sidecar.istio.io/inject": "false"
        }
      },
      "spec": {
        "affinity": {
          "nodeAffinity": {
            "preferredDuringSchedulingIgnoredDuringExecution": null,
            "requiredDuringSchedulingIgnoredDuringExecution": null
          }
        },
        "containers": [
          {
            "args": [
              "proxy",
              "router",
              "--domain",
              "$(POD_NAMESPACE).svc.cluster.local",
              "--proxyLogLevel=warning",
              "--proxyComponentLogLevel=misc:error",
              std.join("", ["--log_output_level=default:", log_level])
            ],
            "env": [
              {
                "name": "ISTIO_META_ROUTER_MODE",
                "value": "sni-dnat"
              },
              {
                "name": "JWT_POLICY",
                "value": "third-party-jwt"
              },
              {
                "name": "PILOT_CERT_PROVIDER",
                "value": "istiod"
              },
              {
                "name": "CA_ADDR",
                "value": "istiod.istio-system.svc:15012"
              },
              {
                "name": "NODE_NAME",
                "valueFrom": {
                  "fieldRef": {
                    "apiVersion": "v1",
                    "fieldPath": "spec.nodeName"
                  }
                }
              },
              {
                "name": "POD_NAME",
                "valueFrom": {
                  "fieldRef": {
                    "apiVersion": "v1",
                    "fieldPath": "metadata.name"
                  }
                }
              },
              {
                "name": "POD_NAMESPACE",
                "valueFrom": {
                  "fieldRef": {
                    "apiVersion": "v1",
                    "fieldPath": "metadata.namespace"
                  }
                }
              },
              {
                "name": "INSTANCE_IP",
                "valueFrom": {
                  "fieldRef": {
                    "apiVersion": "v1",
                    "fieldPath": "status.podIP"
                  }
                }
              },
              {
                "name": "HOST_IP",
                "valueFrom": {
                  "fieldRef": {
                    "apiVersion": "v1",
                    "fieldPath": "status.hostIP"
                  }
                }
              },
              {
                "name": "SERVICE_ACCOUNT",
                "valueFrom": {
                  "fieldRef": {
                    "fieldPath": "spec.serviceAccountName"
                  }
                }
              },
              {
                "name": "ISTIO_META_WORKLOAD_NAME",
                "value": "cluster-local-gateway"
              },
              {
                "name": "ISTIO_META_OWNER",
                "value": "kubernetes://apis/apps/v1/namespaces/istio-system/deployments/cluster-local-gateway"
              },
              {
                "name": "ISTIO_META_MESH_ID",
                "value": "cluster.local"
              },
              {
                "name": "TRUST_DOMAIN",
                "value": "cluster.local"
              },
              {
                "name": "ISTIO_META_UNPRIVILEGED_POD",
                "value": "true"
              },
              {
                "name": "ISTIO_META_CLUSTER_ID",
                "value": "Kubernetes"
              }
            ],
            "image": std.join("", [target_registry, "docker.io/istio/proxyv2:1.16.0"]),
            "name": "istio-proxy",
            "ports": [
              {
                "containerPort": 15020,
                "protocol": "TCP"
              },
              {
                "containerPort": 8080,
                "protocol": "TCP"
              },
              {
                "containerPort": 15090,
                "name": "http-envoy-prom",
                "protocol": "TCP"
              }
            ],
            "readinessProbe": {
              "failureThreshold": 30,
              "httpGet": {
                "path": "/healthz/ready",
                "port": 15021,
                "scheme": "HTTP"
              },
              "initialDelaySeconds": 1,
              "periodSeconds": 2,
              "successThreshold": 1,
              "timeoutSeconds": 1
            },
            "resources": {
              "limits": {
                "cpu": "2000m",
                "memory": "1024Mi"
              },
              "requests": {
                "cpu": "100m",
                "memory": "128Mi"
              }
            },
            "securityContext": {
              "allowPrivilegeEscalation": false,
              "capabilities": {
                "drop": [
                  "ALL"
                ]
              },
              "privileged": false,
              "readOnlyRootFilesystem": true
            },
            "volumeMounts": [
              {
                "mountPath": "/var/run/secrets/workload-spiffe-uds",
                "name": "workload-socket"
              },
              {
                "mountPath": "/var/run/secrets/credential-uds",
                "name": "credential-socket"
              },
              {
                "mountPath": "/var/run/secrets/workload-spiffe-credentials",
                "name": "workload-certs"
              },
              {
                "mountPath": "/etc/istio/proxy",
                "name": "istio-envoy"
              },
              {
                "mountPath": "/etc/istio/config",
                "name": "config-volume"
              },
              {
                "mountPath": "/var/run/secrets/istio",
                "name": "istiod-ca-cert"
              },
              {
                "mountPath": "/var/run/secrets/tokens",
                "name": "istio-token",
                "readOnly": true
              },
              {
                "mountPath": "/var/lib/istio/data",
                "name": "istio-data"
              },
              {
                "mountPath": "/etc/istio/pod",
                "name": "podinfo"
              },
              {
                "mountPath": "/etc/istio/ingressgateway-certs",
                "name": "ingressgateway-certs",
                "readOnly": true
              },
              {
                "mountPath": "/etc/istio/ingressgateway-ca-certs",
                "name": "ingressgateway-ca-certs",
                "readOnly": true
              }
            ] + (
                if time_zone != "UTC" then [
                {
                    "name": "timezone-config",
                    "mountPath": "/etc/localtime"
                },
                ] else []
            )
          }
        ],
        "securityContext": {
          "fsGroup": 1337,
          "runAsGroup": 1337,
          "runAsNonRoot": true,
          "runAsUser": 1337
        },
        "serviceAccountName": "cluster-local-gateway-service-account",
        "volumes": [
          {
            "emptyDir": {},
            "name": "workload-socket"
          },
          {
            "emptyDir": {},
            "name": "credential-socket"
          },
          {
            "emptyDir": {},
            "name": "workload-certs"
          },
          {
            "configMap": {
              "name": "istio-ca-root-cert"
            },
            "name": "istiod-ca-cert"
          },
          {
            "downwardAPI": {
              "items": [
                {
                  "fieldRef": {
                    "fieldPath": "metadata.labels"
                  },
                  "path": "labels"
                },
                {
                  "fieldRef": {
                    "fieldPath": "metadata.annotations"
                  },
                  "path": "annotations"
                }
              ]
            },
            "name": "podinfo"
          },
          {
            "emptyDir": {},
            "name": "istio-envoy"
          },
          {
            "emptyDir": {},
            "name": "istio-data"
          },
          {
            "name": "istio-token",
            "projected": {
              "sources": [
                {
                  "serviceAccountToken": {
                    "audience": "istio-ca",
                    "expirationSeconds": 43200,
                    "path": "istio-token"
                  }
                }
              ]
            }
          },
          {
            "configMap": {
              "name": "istio",
              "optional": true
            },
            "name": "config-volume"
          },
          {
            "name": "ingressgateway-certs",
            "secret": {
              "optional": true,
              "secretName": "istio-ingressgateway-certs"
            }
          },
          {
            "name": "ingressgateway-ca-certs",
            "secret": {
              "optional": true,
              "secretName": "istio-ingressgateway-ca-certs"
            }
          }
        ] + (
            if time_zone != "UTC" then [
            {
                "name": "timezone-config",
                "hostPath": {
                "path": std.join("", ["/usr/share/zoneinfo/", time_zone])
                }
            }
            ] else []
        )
      }
    }
  }
}    
]