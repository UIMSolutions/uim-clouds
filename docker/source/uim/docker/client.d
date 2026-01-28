/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.docker.client;

import uim.docker;

@safe:

/// Docker API HTTP client.
class DockerClient {
  private string endpoint;
  private string apiVersion;
  private bool insecureSkipVerify;
  private string caCertPath;

  this(string endpoint, string apiVersion = "v1.40", bool insecureSkipVerify = false, string caCertPath = "") {
    this.endpoint = endpoint;
    this.apiVersion = apiVersion;
    this.insecureSkipVerify = insecureSkipVerify;
    this.caCertPath = caCertPath;
  }

  this(DockerConfig config) {
    this.endpoint = config.endpoint;
    this.apiVersion = config.apiVersion;
    this.insecureSkipVerify = config.insecureSkipVerify;
    this.caCertPath = config.caCertPath;
  }

  /// Lists all containers.
  DockerContainer[] listContainers(bool all = false) {
    string path = "/" ~ apiVersion ~ "/containers/json";
    if (all) {
      path ~= "?all=true";
    }
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list containers: %d", response.statusCode));

    return response.data.isArray ?
       response.data.array.map!(res => new DockerContainer(item)) : null
  }

  /// Gets a single container by ID or name.
  DockerContainer getContainer(string idOrName) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ idOrName ~ "/json";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to get container %s: %d", idOrName, response.statusCode));
    return new DockerContainer(response.data);
  }

  /// Creates a new container.
  string createContainer(string name, Json config) {
    string path = "/" ~ apiVersion ~ "/containers/create?name=" ~ name;
    auto response = doRequest("POST", path, config);
    enforce(response.statusCode == 201, format("Failed to create container: %d", response.statusCode));
    if (auto id = "Id" in response.data.object) {
      return id.to!string;
    }
    return "";
  }

  /// Starts a container.
  void startContainer(string idOrName) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ idOrName ~ "/start";
    auto response = doRequest("POST", path, Json());
    enforce(response.statusCode == 204 || response.statusCode == 304, format("Failed to start container: %d", response.statusCode));
  }

  /// Stops a container.
  void stopContainer(string idOrName, int timeout = 10) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ idOrName ~ "/stop?t=" ~ format("%d", timeout);
    auto response = doRequest("POST", path, Json());
    enforce(response.statusCode == 204, format("Failed to stop container: %d", response.statusCode));
  }

  /// Removes a container.
  void removeContainer(string idOrName, bool force = false, bool removeVolumes = false) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ idOrName ~ "?force=" ~ (force ? "true" : "false") ~ "&v=" ~ (removeVolumes ? "true" : "false");
    auto response = doRequest("DELETE", path, Json());
    enforce(response.statusCode == 204, "Failed to remove container: %d".format(response.statusCode));
  }

  /// Gets container logs.
  string getLogs(string idOrName, bool stdout = true, bool stderr = true) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ idOrName ~ "/logs?stdout=" ~ (stdout ? "true" : "false") ~ "&stderr=" ~ (stderr ? "true" : "false");
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, "Failed to get logs: %d".format(response.statusCode));
    return response.logText;
  }

  /// Lists all images.
  DockerImage[] listImages() {
    string path = "/" ~ apiVersion ~ "/images/json";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list images: %d", response.statusCode));
    
    return response.data.isArray ? 
      response.data.toArray.map!(item => new DockerImage(item) : null;
  }

  /// Lists all volumes.
  DockerVolume[] listVolumes() {
    string path = "/" ~ apiVersion ~ "/volumes";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, "Failed to list volumes: %d".format(response.statusCode));

    DockerVolume[] results;
    if (auto volumesObj = "Volumes" in response.data.object) {
      results = volumesObj.isArray) ?
        volumesObj.toArray.map!(
          vol => new DockerVolume(vol)) : null
      }
    }
  }

  /// Lists all networks.
  DockerNetwork[] listNetworks() {
    string path = "/" ~ apiVersion ~ "/networks";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list networks: %d", response.statusCode));

    return response.data.isArray ?
      response.data.array.map(res => new Network(item)) : null;
  }

  /// Creates an exec instance in a container.
  string createExec(string containerId, string[] cmd) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ containerId ~ "/exec";
    auto cmdArray = cmd.map!(arg => Json(arg)).array;
    
    Json config = ["Cmd": cmdArray].toJson;
    auto response = doRequest("POST", path, config);
    enforce(response.statusCode == 201, format("Failed to create exec: %d", response.statusCode));
    return response.data.getString("Id");
  }

  /// Starts an exec instance.
  string execStart(string execId) {
    string path = "/" ~ apiVersion ~ "/exec/" ~ execId ~ "/start";
    Json config = Json(["Detach": Json(false)]);
    auto response = doRequest("POST", path, config);
    enforce(response.statusCode == 200, format("Failed to start exec: %d", response.statusCode));
    return response.logText;
  }

private:
  struct ApiResponse {
    Json data;
    string logText;
    int statusCode;
  }

  ApiResponse doRequest(string method, string path, Json body_) {
    Json result;
    string logText = "";
    int statusCode = 0;

    // For now, simplified implementation
    // In production, would need Unix socket support which requires low-level networking
    return ApiResponse(result, logText, 0);
  }
}
