/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.kubernetes.classes.client;

import uim.kubernetes;
@safe:
@trusted:

/// Kubernetes API HTTP client.
class K8SClient {
  private string apiServer;
  private string token;
  private bool insecureSkipVerify;
  private string caCertPath;

  this(string apiServer, string token, bool insecureSkipVerify = false, string caCertPath = "") {
    this.apiServer = apiServer;
    this.token = token;
    this.insecureSkipVerify = insecureSkipVerify;
    this.caCertPath = caCertPath;
  }

  this(K8SConfig config) {
    this.apiServer = config.apiServer;
    this.token = config.token;
    this.insecureSkipVerify = config.insecureSkipVerify;
    this.caCertPath = config.caCertPath;
  }

  /// Lists resources of a given kind in a namespace.
  K8SResource[] listResources(string apiVersion, string kind, string namespace_) {
    string path = "/api/" ~ apiVersion ~ "/namespaces/" ~ namespace_ ~ "/" ~ kind;
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list %s: %d", kind, response.statusCode));

    auto items = response.data["items"].array;
    K8SResource[] results = items.map!((item => new K8SResource(item))).array;
    return results;
  }

  /// Gets a single resource by name.
  K8SResource getResource(string apiVersion, string kind, string namespace_, string name) {
    string path = "/api/" ~ apiVersion ~ "/namespaces/" ~ namespace_ ~ "/" ~ kind ~ "/" ~ name;
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to get %s %s: %d", kind, name, response.statusCode));
    return new K8SResource(response.data);
  }

  /// Creates a new resource.
  K8SResource createResource(string apiVersion, string kind, string namespace_, Json spec) {
    string path = "/api/" ~ apiVersion ~ "/namespaces/" ~ namespace_ ~ "/" ~ kind;
    auto response = doRequest("POST", path, spec);
    enforce(response.statusCode == 201, format("Failed to create %s: %d", kind, response.statusCode));
    return new K8SResource(response.data);
  }

  /// Updates an existing resource.
  K8SResource updateResource(string apiVersion, string kind, string namespace_, string name, Json spec) {
    string path = "/api/" ~ apiVersion ~ "/namespaces/" ~ namespace_ ~ "/" ~ kind ~ "/" ~ name;
    auto response = doRequest("PUT", path, spec);
    enforce(response.statusCode == 200, format("Failed to update %s %s: %d", kind, name, response.statusCode));
    return new K8SResource(response.data);
  }

  /// Deletes a resource.
  void deleteResource(string apiVersion, string kind, string namespace_, string name) {
    string path = "/api/" ~ apiVersion ~ "/namespaces/" ~ namespace_ ~ "/" ~ kind ~ "/" ~ name;
    auto response = doRequest("DELETE", path, Json());
    enforce(response.statusCode == 200 || response.statusCode == 202, format("Failed to delete %s %s: %d", kind, name, response.statusCode));
  }

  /// Lists Pods in a namespace.
  K8SPod[] listPods(string namespace_ = "default") {
    auto resources = listResources("v1", "pods", namespace_);
    K8SPod[] pods;
    foreach (res; resources) {
      pods ~= new K8SPod(res);
    }
    return pods;
  }

  /// Gets a single Pod.
  K8SPod getPod(string namespace_, string name) {
    return new K8SPod(getResource("v1", "pods", namespace_, name));
  }

  /// Lists Deployments in a namespace.
  K8SDeployment[] listDeployments(string namespace_ = "default") {
    auto resources = listResources("apps/v1", "deployments", namespace_);
    return resources.map!(res => new K8SDeployment(res)).array;
  }

  /// Gets a single Deployment.
  K8SDeployment getDeployment(string namespace_, string name) {
    return new K8SDeployment(getResource("apps/v1", "deployments", namespace_, name));
  }

  /// Lists Services in a namespace.
  K8SService[] listServices(string namespace_ = "default") {
    auto resources = listResources("v1", "services", namespace_);
    return resources.map!(res => new K8SService(res)).array;
  }

  /// Gets a single Service.
  K8SService getService(string namespace_, string name) {
    return new K8SService(getResource("v1", "services", namespace_, name));
  }

  /// Lists ConfigMaps in a namespace.
  K8SConfigMap[] listConfigMaps(string namespace_ = "default") {
    auto resources = listResources("v1", "configmaps", namespace_);
    return resources.map!(res => new K8SConfigMap(res)).array;
  }

  /// Gets a single ConfigMap.
  K8SConfigMap getConfigMap(string namespace_, string name) {
    return new K8SConfigMap(getResource("v1", "configmaps", namespace_, name));
  }

  /// Watches for events on a resource kind.
  K8SWatcher watchResources(string apiVersion, string kind, string namespace_) {
    string path = "/api/" ~ apiVersion ~ "/watch/namespaces/" ~ namespace_ ~ "/" ~ kind;
    return K8SWatcher(this, path);
  }

  /// Watches Pods in a namespace.
  K8SWatcher watchPods(string namespace_ = "default") {
    return watchResources("v1", "pods", namespace_);
  }

private:
  struct ApiResponse {
    Json data;
    int statusCode;
  }

  ApiResponse doRequest(string method, string path, Json body_) {
    auto url = apiServer ~ path;

    Json result;
    int statusCode = 0;

    requestHTTP(url,
      (scope HTTPClientRequest req) {
        req.method = parseHttpMethod(method);
        req.headers["Authorization"] = "Bearer " ~ token;
        req.headers["Content-Type"] = "application/json";
        if (insecureSkipVerify) {
          req.sslContext = null;
        }
        if (body_.type != Json.Type.null_) {
          req.writeBody(body_.toString());
        }
      },
      (scope HTTPClientResponse res) {
        statusCode = res.statusCode;
        auto bodyStr = res.bodyReader.readAllUTF8();
        if (bodyStr.length > 0) {
          try {
            result = parseJsonString(bodyStr);
          } catch (Exception) {
            result = Json(bodyStr);
          }
        }
      }
    );

    return ApiResponse(result, statusCode);
  }

  import vibe.http.common : HTTPMethod;

  HTTPMethod parseHttpMethod(string method) {
    if (method == "GET") return HTTPMethod.GET;
    if (method == "POST") return HTTPMethod.POST;
    if (method == "PUT") return HTTPMethod.PUT;
    if (method == "DELETE") return HTTPMethod.DELETE;
    if (method == "PATCH") return HTTPMethod.PATCH;
    return HTTPMethod.GET;
  }
}
