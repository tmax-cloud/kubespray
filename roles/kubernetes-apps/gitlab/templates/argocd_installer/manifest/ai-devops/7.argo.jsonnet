function (
    is_offline="false",
    private_registry="172.22.6.2:5000",
    ai_devops_namespace="kubeflow",
    istio_namespace="istio-system",
    knative_namespace="knative-serving",
    custom_domain_name="tmaxcloud.org",
    notebook_svc_type="Ingress"
)

local target_registry = if is_offline == "false" then "" else private_registry + "/";
local argo_image_tag = "v2.12.10";
[
{
  "apiVersion": "apiextensions.k8s.io/v1beta1",
  "kind": "CustomResourceDefinition",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "clusterworkflowtemplates.argoproj.io"
  },
  "spec": {
    "group": "argoproj.io",
    "names": {
      "kind": "ClusterWorkflowTemplate",
      "listKind": "ClusterWorkflowTemplateList",
      "plural": "clusterworkflowtemplates",
      "shortNames": [
        "clusterwftmpl",
        "cwft"
      ],
      "singular": "clusterworkflowtemplate"
    },
    "scope": "Cluster",
    "version": "v1alpha1",
    "versions": [
      {
        "name": "v1alpha1",
        "served": true,
        "storage": true
      }
    ]
  }
},
{
  "apiVersion": "apiextensions.k8s.io/v1beta1",
  "kind": "CustomResourceDefinition",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "cronworkflows.argoproj.io"
  },
  "spec": {
    "group": "argoproj.io",
    "names": {
      "kind": "CronWorkflow",
      "listKind": "CronWorkflowList",
      "plural": "cronworkflows",
      "shortNames": [
        "cwf",
        "cronwf"
      ],
      "singular": "cronworkflow"
    },
    "scope": "Namespaced",
    "version": "v1alpha1",
    "versions": [
      {
        "name": "v1alpha1",
        "served": true,
        "storage": true
      }
    ]
  }
},
{
  "apiVersion": "apiextensions.k8s.io/v1beta1",
  "kind": "CustomResourceDefinition",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "workfloweventbindings.argoproj.io"
  },
  "spec": {
    "group": "argoproj.io",
    "names": {
      "kind": "WorkflowEventBinding",
      "listKind": "WorkflowEventBindingList",
      "plural": "workfloweventbindings",
      "shortNames": [
        "wfeb"
      ],
      "singular": "workfloweventbinding"
    },
    "scope": "Namespaced",
    "version": "v1alpha1",
    "versions": [
      {
        "name": "v1alpha1",
        "served": true,
        "storage": true
      }
    ]
  }
},
{
  "apiVersion": "apiextensions.k8s.io/v1beta1",
  "kind": "CustomResourceDefinition",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "workflows.argoproj.io"
  },
  "spec": {
    "additionalPrinterColumns": [
      {
        "JSONPath": ".status.phase",
        "description": "Status of the workflow",
        "name": "Status",
        "type": "string"
      },
      {
        "JSONPath": ".status.startedAt",
        "description": "When the workflow was started",
        "format": "date-time",
        "name": "Age",
        "type": "date"
      }
    ],
    "group": "argoproj.io",
    "names": {
      "kind": "Workflow",
      "listKind": "WorkflowList",
      "plural": "workflows",
      "shortNames": [
        "wf"
      ],
      "singular": "workflow"
    },
    "scope": "Namespaced",
    "subresources": {},
    "version": "v1alpha1",
    "versions": [
      {
        "name": "v1alpha1",
        "served": true,
        "storage": true
      }
    ]
  }
},
{
  "apiVersion": "apiextensions.k8s.io/v1beta1",
  "kind": "CustomResourceDefinition",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "workflowtemplates.argoproj.io"
  },
  "spec": {
    "group": "argoproj.io",
    "names": {
      "kind": "WorkflowTemplate",
      "listKind": "WorkflowTemplateList",
      "plural": "workflowtemplates",
      "shortNames": [
        "wftmpl"
      ],
      "singular": "workflowtemplate"
    },
    "scope": "Namespaced",
    "version": "v1alpha1",
    "versions": [
      {
        "name": "v1alpha1",
        "served": true,
        "storage": true
      }
    ]
  }
},
{
  "apiVersion": "v1",
  "kind": "ServiceAccount",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "argo",
    "namespace": ai_devops_namespace
  }
},
{
  "apiVersion": "v1",
  "kind": "ServiceAccount",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "argo-server",
    "namespace": ai_devops_namespace
  }
},
{
  "apiVersion": "rbac.authorization.k8s.io/v1",
  "kind": "Role",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "argo-role",
    "namespace": ai_devops_namespace
  },
  "rules": [
    {
      "apiGroups": [
        ""
      ],
      "resources": [
        "secrets"
      ],
      "verbs": [
        "get"
      ]
    }
  ]
},
{
  "apiVersion": "rbac.authorization.k8s.io/v1",
  "kind": "ClusterRole",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo",
      "rbac.authorization.k8s.io/aggregate-to-admin": "true"
    },
    "name": "argo-aggregate-to-admin"
  },
  "rules": [
    {
      "apiGroups": [
        "argoproj.io"
      ],
      "resources": [
        "workflows",
        "workflows/finalizers",
        "workfloweventbindings",
        "workfloweventbindings/finalizers",
        "workflowtemplates",
        "workflowtemplates/finalizers",
        "cronworkflows",
        "cronworkflows/finalizers",
        "clusterworkflowtemplates",
        "clusterworkflowtemplates/finalizers"
      ],
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ]
    }
  ]
},
{
  "apiVersion": "rbac.authorization.k8s.io/v1",
  "kind": "ClusterRole",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo",
      "rbac.authorization.k8s.io/aggregate-to-edit": "true"
    },
    "name": "argo-aggregate-to-edit"
  },
  "rules": [
    {
      "apiGroups": [
        "argoproj.io"
      ],
      "resources": [
        "workflows",
        "workflows/finalizers",
        "workfloweventbindings",
        "workfloweventbindings/finalizers",
        "workflowtemplates",
        "workflowtemplates/finalizers",
        "cronworkflows",
        "cronworkflows/finalizers",
        "clusterworkflowtemplates",
        "clusterworkflowtemplates/finalizers"
      ],
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ]
    }
  ]
},
{
  "apiVersion": "rbac.authorization.k8s.io/v1",
  "kind": "ClusterRole",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo",
      "rbac.authorization.k8s.io/aggregate-to-view": "true"
    },
    "name": "argo-aggregate-to-view"
  },
  "rules": [
    {
      "apiGroups": [
        "argoproj.io"
      ],
      "resources": [
        "workflows",
        "workflows/finalizers",
        "workfloweventbindings",
        "workfloweventbindings/finalizers",
        "workflowtemplates",
        "workflowtemplates/finalizers",
        "cronworkflows",
        "cronworkflows/finalizers",
        "clusterworkflowtemplates",
        "clusterworkflowtemplates/finalizers"
      ],
      "verbs": [
        "get",
        "list",
        "watch"
      ]
    }
  ]
},
{
  "apiVersion": "rbac.authorization.k8s.io/v1",
  "kind": "ClusterRole",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "argo-cluster-role"
  },
  "rules": [
    {
      "apiGroups": [
        ""
      ],
      "resources": [
        "pods",
        "pods/exec"
      ],
      "verbs": [
        "create",
        "get",
        "list",
        "watch",
        "update",
        "patch",
        "delete"
      ]
    },
    {
      "apiGroups": [
        ""
      ],
      "resources": [
        "configmaps"
      ],
      "verbs": [
        "get",
        "watch",
        "list"
      ]
    },
    {
      "apiGroups": [
        ""
      ],
      "resources": [
        "persistentvolumeclaims"
      ],
      "verbs": [
        "create",
        "delete",
        "get"
      ]
    },
    {
      "apiGroups": [
        "argoproj.io"
      ],
      "resources": [
        "workflows",
        "workflows/finalizers"
      ],
      "verbs": [
        "get",
        "list",
        "watch",
        "update",
        "patch",
        "delete",
        "create"
      ]
    },
    {
      "apiGroups": [
        "argoproj.io"
      ],
      "resources": [
        "workflowtemplates",
        "workflowtemplates/finalizers",
        "clusterworkflowtemplates",
        "clusterworkflowtemplates/finalizers"
      ],
      "verbs": [
        "get",
        "list",
        "watch"
      ]
    },
    {
      "apiGroups": [
        ""
      ],
      "resources": [
        "serviceaccounts"
      ],
      "verbs": [
        "get",
        "list"
      ]
    },
    {
      "apiGroups": [
        "argoproj.io"
      ],
      "resources": [
        "cronworkflows",
        "cronworkflows/finalizers"
      ],
      "verbs": [
        "get",
        "list",
        "watch",
        "update",
        "patch",
        "delete"
      ]
    },
    {
      "apiGroups": [
        ""
      ],
      "resources": [
        "events"
      ],
      "verbs": [
        "create",
        "patch"
      ]
    },
    {
      "apiGroups": [
        "policy"
      ],
      "resources": [
        "poddisruptionbudgets"
      ],
      "verbs": [
        "create",
        "get",
        "delete"
      ]
    }
  ]
},
{
  "apiVersion": "rbac.authorization.k8s.io/v1",
  "kind": "ClusterRole",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "argo-server-cluster-role"
  },
  "rules": [
    {
      "apiGroups": [
        ""
      ],
      "resources": [
        "configmaps"
      ],
      "verbs": [
        "get",
        "watch",
        "list"
      ]
    },
    {
      "apiGroups": [
        ""
      ],
      "resources": [
        "secrets"
      ],
      "verbs": [
        "get",
        "create"
      ]
    },
    {
      "apiGroups": [
        ""
      ],
      "resources": [
        "pods",
        "pods/exec",
        "pods/log"
      ],
      "verbs": [
        "get",
        "list",
        "watch",
        "delete"
      ]
    },
    {
      "apiGroups": [
        ""
      ],
      "resources": [
        "events"
      ],
      "verbs": [
        "watch",
        "create",
        "patch"
      ]
    },
    {
      "apiGroups": [
        ""
      ],
      "resources": [
        "serviceaccounts"
      ],
      "verbs": [
        "get",
        "list"
      ]
    },
    {
      "apiGroups": [
        "argoproj.io"
      ],
      "resources": [
        "workflows",
        "workfloweventbindings",
        "workflowtemplates",
        "cronworkflows",
        "clusterworkflowtemplates"
      ],
      "verbs": [
        "create",
        "get",
        "list",
        "watch",
        "update",
        "patch",
        "delete"
      ]
    }
  ]
},
{
  "apiVersion": "rbac.authorization.k8s.io/v1",
  "kind": "RoleBinding",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "argo-binding",
    "namespace": ai_devops_namespace
  },
  "roleRef": {
    "apiGroup": "rbac.authorization.k8s.io",
    "kind": "Role",
    "name": "argo-role"
  },
  "subjects": [
    {
      "kind": "ServiceAccount",
      "name": "argo",
      "namespace": ai_devops_namespace
    }
  ]
},
{
  "apiVersion": "rbac.authorization.k8s.io/v1",
  "kind": "ClusterRoleBinding",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "argo-binding"
  },
  "roleRef": {
    "apiGroup": "rbac.authorization.k8s.io",
    "kind": "ClusterRole",
    "name": "argo-cluster-role"
  },
  "subjects": [
    {
      "kind": "ServiceAccount",
      "name": "argo",
      "namespace": ai_devops_namespace
    }
  ]
},
{
  "apiVersion": "rbac.authorization.k8s.io/v1",
  "kind": "ClusterRoleBinding",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "argo-server-binding"
  },
  "roleRef": {
    "apiGroup": "rbac.authorization.k8s.io",
    "kind": "ClusterRole",
    "name": "argo-server-cluster-role"
  },
  "subjects": [
    {
      "kind": "ServiceAccount",
      "name": "argo-server",
      "namespace": ai_devops_namespace
    }
  ]
},
{
  "apiVersion": "v1",
  "data": {
    "cluster-name": "",
    "clusterDomain": "cluster.local",
    "istio-namespace": istio_namespace,
    "userid-header": "kubeflow-userid",
    "userid-prefix": ""
  },
  "kind": "ConfigMap",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "kubeflow-config",
    "namespace": ai_devops_namespace
  }
},
{
  "apiVersion": "v1",
  "data": {
    "config": "{\n  containerRuntimeExecutor: \"pns\"\n}\n"
  },
  "kind": "ConfigMap",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "workflow-controller-configmap",
    "namespace": ai_devops_namespace
  }
},
{
  "apiVersion": "v1",
  "data": {
    "artifactRepositoryAccessKeySecretKey": "accesskey",
    "artifactRepositoryAccessKeySecretName": "mlpipeline-minio-artifact",
    "artifactRepositoryBucket": "mlpipeline",
    "artifactRepositoryEndpoint": "minio-service.kubeflow:9000",
    "artifactRepositoryInsecure": "true",
    "artifactRepositoryKeyPrefix": "artifacts",
    "artifactRepositorySecretKeySecretKey": "secretkey",
    "artifactRepositorySecretKeySecretName": "mlpipeline-minio-artifact",
    "clusterDomain": "cluster.local",
    "containerRuntimeExecutor": "pns",
    "executorImage": std.join("", [target_registry, "docker.io/argoproj/argoexec:", argo_image_tag]),
    "namespace": ""
  },
  "kind": "ConfigMap",
  "metadata": {
    "annotations": {},
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "workflow-controller-parameters",
    "namespace": ai_devops_namespace
  }
},
{
  "apiVersion": "v1",
  "kind": "Service",
  "metadata": {
    "labels": {
      "app": "argo-server",
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "argo-server",
    "namespace": ai_devops_namespace
  },
  "spec": {
    "ports": [
      {
        "name": "web",
        "port": 2746,
        "targetPort": 2746
      }
    ],
    "selector": {
      "app": "argo-server",
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    }
  }
},
{
  "apiVersion": "v1",
  "kind": "Service",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "workflow-controller-metrics",
    "namespace": ai_devops_namespace
  },
  "spec": {
    "ports": [
      {
        "name": "metrics",
        "port": 9090,
        "protocol": "TCP",
        "targetPort": 9090
      }
    ],
    "selector": {
      "app": "workflow-controller",
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    }
  }
},
{
  "apiVersion": "apps/v1",
  "kind": "Deployment",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "argo-server",
    "namespace": ai_devops_namespace
  },
  "spec": {
    "selector": {
      "matchLabels": {
        "app": "argo-server",
        "app.kubernetes.io/component": "argo",
        "app.kubernetes.io/name": "argo",
        "kustomize.component": "argo"
      }
    },
    "template": {
      "metadata": {
        "annotations": {
          "sidecar.istio.io/inject": "false"
        },
        "labels": {
          "app": "argo-server",
          "app.kubernetes.io/component": "argo",
          "app.kubernetes.io/name": "argo",
          "kustomize.component": "argo"
        }
      },
      "spec": {
        "containers": [
          {
            "args": [
              "server"
            ],
            "image": std.join("", [target_registry, "docker.io/argoproj/argocli:", argo_image_tag]),
            "name": "argo-server",
            "ports": [
              {
                "containerPort": 2746,
                "name": "web"
              }
            ],
            "readinessProbe": {
              "httpGet": {
                "path": "/",
                "port": 2746,
                "scheme": "HTTP"
              },
              "initialDelaySeconds": 10,
              "periodSeconds": 20
            },
            "volumeMounts": [
              {
                "mountPath": "/tmp",
                "name": "tmp"
              }
            ]
          }
        ],
        "nodeSelector": {
          "kubernetes.io/os": "linux"
        },
        "securityContext": {
          "runAsNonRoot": true
        },
        "serviceAccountName": "argo-server",
        "volumes": [
          {
            "emptyDir": {},
            "name": "tmp"
          }
        ]
      }
    }
  }
},
{
  "apiVersion": "apps/v1",
  "kind": "Deployment",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "workflow-controller",
    "namespace": ai_devops_namespace
  },
  "spec": {
    "selector": {
      "matchLabels": {
        "app": "workflow-controller",
        "app.kubernetes.io/component": "argo",
        "app.kubernetes.io/name": "argo",
        "kustomize.component": "argo"
      }
    },
    "template": {
      "metadata": {
        "annotations": {
          "sidecar.istio.io/inject": "false"
        },
        "labels": {
          "app": "workflow-controller",
          "app.kubernetes.io/component": "argo",
          "app.kubernetes.io/name": "argo",
          "kustomize.component": "argo"
        }
      },
      "spec": {
        "containers": [
          {
            "args": [
              "--configmap",
              "workflow-controller-configmap",
              "--executor-image",
              "argoproj/argoexec:v2.12.10"
            ],
            "command": [
              "workflow-controller"
            ],
            "image": std.join("", [target_registry, "docker.io/argoproj/workflow-controller:", argo_image_tag]),
            "livenessProbe": {
              "httpGet": {
                "path": "/metrics",
                "port": "metrics"
              },
              "initialDelaySeconds": 30,
              "periodSeconds": 30
            },
            "name": "workflow-controller",
            "ports": [
              {
                "containerPort": 9090,
                "name": "metrics"
              }
            ]
          }
        ],
        "nodeSelector": {
          "kubernetes.io/os": "linux"
        },
        "securityContext": {
          "runAsNonRoot": true
        },
        "serviceAccountName": "argo"
      }
    }
  }
},
{
  "apiVersion": "app.k8s.io/v1beta1",
  "kind": "Application",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "argo",
    "namespace": ai_devops_namespace
  },
  "spec": {
    "addOwnerRef": true,
    "componentKinds": [
      {
        "group": "core",
        "kind": "ConfigMap"
      },
      {
        "group": "apps",
        "kind": "Deployment"
      },
      {
        "group": "core",
        "kind": "ServiceAccount"
      },
      {
        "group": "core",
        "kind": "Service"
      },
      {
        "group": "networking.istio.io",
        "kind": "VirtualService"
      }
    ],
    "descriptor": {
      "description": "Argo Workflows is an open source container-native workflow engine for orchestrating parallel jobs on Kubernetes",
      "keywords": [
        "argo",
        "kubeflow"
      ],
      "links": [
        {
          "description": "About",
          "url": "https://github.com/argoproj/argo"
        }
      ],
      "maintainers": [],
      "owners": [],
      "type": "argo",
      "version": "v1beta1"
    },
    "selector": {
      "matchLabels": {
        "app.kubernetes.io/component": "argo",
        "app.kubernetes.io/name": "argo"
      }
    }
  }
},
{
  "apiVersion": "networking.istio.io/v1alpha3",
  "kind": "VirtualService",
  "metadata": {
    "labels": {
      "app.kubernetes.io/component": "argo",
      "app.kubernetes.io/name": "argo",
      "kustomize.component": "argo"
    },
    "name": "argo-ui",
    "namespace": ai_devops_namespace
  },
  "spec": {
    "gateways": [
      "kubeflow-gateway"
    ],
    "hosts": [
      "*"
    ],
    "http": [
      {
        "match": [
          {
            "uri": {
              "prefix": "/argo/"
            }
          }
        ],
        "rewrite": {
          "uri": "/"
        },
        "route": [
          {
            "destination": {
              "host": "argo-ui.kubeflow.svc.cluster.local",
              "port": {
                "number": 80
              }
            }
          }
        ]
      }
    ]
  }
}
]