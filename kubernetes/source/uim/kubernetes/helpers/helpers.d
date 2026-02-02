/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.kubernetes.helpers.helpers;

import uim.kubernetes;

mixin(ShowModule!());

@safe:

/// Creates a Pod manifest JSON.
Json createPodManifest(string name, string image, string namespace_ = "default") {
  Json pod = Json([
    "apiVersion": Json("v1"),
    "kind": Json("Pod"),
    "metadata": Json([
      "name": Json(name),
      "namespace": Json(namespace_)
    ]),
    "spec": Json([
      "containers": Json([
        Json([
          "name": Json(name),
          "image": Json(image),
          "imagePullPolicy": Json("IfNotPresent")
        ])
      ])
    ])
  ]);
  return pod;
}

/// Creates a Deployment manifest JSON.
Json createDeploymentManifest(string name, string image, size_t replicas = 1, string namespace_ = "default") {
  Json deployment = Json([
    "apiVersion": Json("apps/v1"),
    "kind": Json("Deployment"),
    "metadata": Json([
      "name": Json(name),
      "namespace": Json(namespace_)
    ]),
    "spec": Json([
      "replicas": Json(cast(long) replicas),
      "selector": Json([
        "matchLabels": Json([
          "app": Json(name)
        ])
      ]),
      "template": Json([
        "metadata": Json([
          "labels": Json([
            "app": Json(name)
          ])
        ]),
        "spec": Json([
          "containers": Json([
            Json([
              "name": Json(name),
              "image": Json(image),
              "imagePullPolicy": Json("IfNotPresent")
            ])
          ])
        ])
      ])
    ])
  ]);
  return deployment;
}

/// Creates a Service manifest JSON.
Json createServiceManifest(string name, string appLabel, ushort port, string namespace_ = "default") {
  Json service = Json([
    "apiVersion": Json("v1"),
    "kind": Json("Service"),
    "metadata": Json([
      "name": Json(name),
      "namespace": Json(namespace_)
    ]),
    "spec": Json([
      "type": Json("ClusterIP"),
      "selector": Json([
        "app": Json(appLabel)
      ]),
      "ports": Json([
        Json([
          "protocol": Json("TCP"),
          "port": Json(cast(long) port),
          "targetPort": Json(cast(long) port)
        ])
      ])
    ])
  ]);
  return service;
}

/// Creates a ConfigMap manifest JSON.
Json createConfigMapManifest(string name, string[string] data, string namespace_ = "default") {
  Json[string] dataObj;
  foreach (key, value; data) {
    dataObj[key] = Json(value);
  }

  Json configMap = Json([
    "apiVersion": Json("v1"),
    "kind": Json("ConfigMap"),
    "metadata": Json([
      "name": Json(name),
      "namespace": Json(namespace_)
    ]),
    "data": Json(dataObj)
  ]);
  return configMap;
}

/// Extracts the container image from a Pod spec.
string getContainerImage(Json pod) @trusted {
  if (auto spec = "spec" in pod.object) {
    if (auto containers = "containers" in spec.object) {
      if (containers.type == Json.Type.array && containers.array.length > 0) {
        if (auto image = "image" in containers.array[0].object) {
          return image.toString;
        }
      }
    }
  }
  return "";
}

/// Checks if a resource is in a terminal state.
bool isTerminal(Json resource) @trusted {
  if (auto metadata = "metadata" in resource.object) {
    if (auto delTime = "deletionTimestamp" in metadata.object) {
      if (delTime.type == Json.Type.toStringing) {
        return true;
      }
    }
  }
  return false;
}

/// Gets the resource version from metadata.
string getResourceVersion(Json resource) @trusted {
  if (auto metadata = "metadata" in resource.object) {
    if (auto rv = "resourceVersion" in metadata.object) {
      return rv.toString;
    }
  }
  return "";
}
