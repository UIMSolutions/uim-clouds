/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.kubernetes.classes.config;

import uim.kubernetes;
@safe:

// Configuration for Kubernetes client authentication and API server access
struct K8SConfig {
  string apiServer;
  string token;
  bool insecureSkipVerify = false;
  string caCertPath = "";
}

/// Creates a config from in-cluster service account.
K8SConfig inClusterConfig() @trusted {
  enum saDir = "/var/run/secrets/kubernetes.io/serviceaccount";
  enum hostPath = saDir ~ "/ca.crt";
  enum tokenPath = saDir ~ "/token";

  string host = "https://kubernetes.default.svc.cluster.local:443";
  auto hostEnv = std.process.environment.get("KUBERNETES_SERVICE_HOST");
  auto portEnv = std.process.environment.get("KUBERNETES_SERVICE_PORT");
  if (hostEnv.length > 0 && portEnv.length > 0) {
    host = "https://" ~ hostEnv ~ ":" ~ portEnv;
  }

  enforce(exists(tokenPath), "Service account token not found: " ~ tokenPath);
  auto token = readText(tokenPath).strip();

  K8SConfig cfg = new K8SConfig();
  cfg.apiServer = host;
  cfg.token = token;
  if (exists(hostPath)) {
    cfg.caCertPath = hostPath;
  }
  return cfg;
}

/// Loads config from kubeconfig file (simplified; loads first context).
K8SConfig loadKubeconfig(string path = "") @trusted {
  if (path.length == 0) {
    path = expandTilde("~/.kube/config");
  }

  enforce(exists(path), "Kubeconfig not found: " ~ path);
  auto content = readText(path);
  auto json = parseJsonString(content);

  // Find cluster and context
  string currentContext = json["current-context"].to!string;
  auto contexts = json["contexts"].array;
  Json* activeCtx;
  foreach (ref ctx; contexts) {
    if (ctx["name"].to!string == currentContext) {
      activeCtx = &ctx;
      break;
    }
  }
  enforce(activeCtx !is null, "Current context not found");

  string clusterName = activeCtx.object["context"]["cluster"].to!string;
  auto clusters = json["clusters"].array;
  Json* activeCluster;
  foreach (ref cls; clusters) {
    if (cls["name"].to!string == clusterName) {
      activeCluster = &cls;
      break;
    }
  }
  enforce(activeCluster !is null, "Cluster not found");

  K8SConfig cfg = new K8SConfig();
  cfg.apiServer = activeCluster.object["cluster"]["server"].to!string;
  cfg.insecureSkipVerify = activeCluster.object["cluster"].object.get("insecure-skip-tls-verify", Json(false)).type == Json.Type.true_;
  if (auto caCert = "certificate-authority" in activeCluster.object["cluster"].object) {
    cfg.caCertPath = caCert.to!string;
  }

  // For now, we skip bearer token extraction from kubeconfig; use in-cluster or explicit token
  return cfg;
}

