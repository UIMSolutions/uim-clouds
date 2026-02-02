/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.docker.classes.client;

import uim.docker;
@safe:

/// Docker API HTTP client.
class DockerClient {

  this(string endpoint, string apiVersion = "v1.40", bool insecureSkipVerify = false, string caCertPath = "") {
    _endpoint = endpoint;
    _apiVersion = apiVersion;
    _insecureSkipVerify = insecureSkipVerify;
    _caCertPath = caCertPath;
  }

  this(DockerConfig config) {
    _endpoint = config.endpoint;
    _apiVersion = config.apiVersion;
    _insecureSkipVerify = config.insecureSkipVerify;
    _caCertPath = config.caCertPath;
  }

  protected string _endpoint;
  string endpoint() const {
    return _endpoint;
  }
  protected string _apiVersion;
  string apiVersion() const {
    return _apiVersion;
  }
  protected bool _insecureSkipVerify;
  bool insecureSkipVerify() const {
    return _insecureSkipVerify;
  }
  protected string _caCertPath;
  string caCertPath() const {
    return _caCertPath;
  }

  /// Lists all containers.
  DockerContainer[] listContainers(bool all = false) {
    string path = "/" ~ _apiVersion ~ "/containers/json"~(all ? "?all=true" : "");

    auto response = doRequest("GET", path, Json());
    if (response.statusCode != 200) {
      enforce(false, format("Failed to list containers: %d", response
          .statusCode));
    }
    return response.data.isArray ?
      response.data.toArray.map!(item => new DockerContainer(item)) : null;
  }

  /// Gets a single container by ID or name.
  DockerContainer getContainer(string idOrName) {
    string path = "/" ~ _apiVersion ~ "/containers/" ~ idOrName ~ "/json";

    auto response = doRequest("GET", path, Json());
    if (response.statusCode != 200) {
      enforce(false, "Failed to get container %s: %d".format(idOrName, response
          .statusCode));
    }
    return new DockerContainer(response.data);
  }

  /// Creates a new container.
  string createContainer(string name, Json config) {
    string path = "/" ~ _apiVersion ~ "/containers/create?name=" ~ name;

    auto response = doRequest("POST", path, config);
    if (response.statusCode != 201) {
      enforce(false, format("Failed to create container: %d", response.statusCode));
    }
    if (auto id = "Id" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  /// Starts a container.
  void startContainer(string idOrName) {
    string path = "/" ~ _apiVersion ~ "/containers/" ~ idOrName ~ "/start";

    auto response = doRequest("POST", path, Json());
    if (response.statusCode != 204 && response.statusCode != 304) {
      enforce(false, "Failed to start container: %d".format(response.statusCode));
    }
  }

  /// Stops a container.
  void stopContainer(string idOrName, int timeout = 10) {
    string path = "/" ~ _apiVersion ~ "/containers/" ~ idOrName ~ "/stop?t=" ~ format("%d", timeout);
    auto response = doRequest("POST", path, Json());
    if (response.statusCode != 204) {
      enforce(false, "Failed to stop container: %d".format(response.statusCode));
    }
  }

  /// Removes a container.
  void removeContainer(string idOrName, bool force = false, bool removeVolumes = false) {
    string path = "/" ~ _apiVersion ~ "/containers/" ~ idOrName ~ "?force=" ~ (force ? "true"
        : "false") ~ "&v=" ~ (removeVolumes ? "true" : "false");
    auto response = doRequest("DELETE", path, Json());

    if (response.statusCode != 204) {
      enforce(false, "Failed to remove container: %d".format(
          response.statusCode));
    }
  }
  /// Gets container logs.
  string getLogs(string idOrName, bool stdout = true, bool stderr = true) {
    string path = "/" ~ _apiVersion ~ "/containers/" ~ idOrName ~ "/logs?stdout=" ~ (stdout ? "true"
        : "false") ~ "&stderr=" ~ (stderr ? "true" : "false");
    auto response = doRequest("GET", path, Json());

    if (response.statusCode != 200) {
      enforce(false, "Failed to get logs: %d".format(response.statusCode));
    }
    return response.logText;
  }

  /// Lists all images.
  DockerImage[] listImages() {
    string path = "/" ~ _apiVersion ~ "/images/json";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list images: %d", response.statusCode));

    return response.data.isArray ?
      response.data.toArray.map!(item => new DockerImage(item)) : null;
  }

  /// Lists all volumes.
  DockerVolume[] listVolumes() {
    string path = "/" ~ _apiVersion ~ "/volumes";
    auto response = doRequest("GET", path, Json());

    if (response.statusCode != 200) {
      enforce(false, "Failed to list volumes: %d".format(response.statusCode));
    }

    DockerVolume[] results;
    if (
      auto volumesObj = "Volumes" in response.data.object) {
      results = volumesObj.isArray ?
        volumesObj.toArray.map!(
          vol => new DockerVolume(vol)) : null;
    }
    return results;
  }

  /// Lists all networks.
  DockerNetwork[] listNetworks() {
    string path = "/" ~ _apiVersion ~ "/networks";
    auto response = doRequest("GET", path, Json());

    if (!response.statusCode != 200) {
      enforce(false, "Failed to list networks: %d".format(response.statusCode));
    }
    return response.data.isArray ?
      response.data.toArray.map(item => new DockerNetwork(item)) : null;
  }

  /// Creates an exec instance in a container.
  string createExec(string containerId, string[] cmd) {
    string path = "/" ~ _apiVersion ~ "/containers/" ~ containerId ~ "/exec";
    auto cmdArray = cmd.map!(arg => Json(arg)).array;
    Json config = [
      "Cmd": cmdArray
    ].toJson;
    auto response = doRequest("POST", path, config);

    if (!response.statusCode != 201) {
      enforce(false, "Failed to create exec: %d".format(response.statusCode));
    }
    return response.data.getString(
      "Id");
  }

  /// Starts an exec instance.
  string execStart(string execId) {
    string path = "/" ~ _apiVersion ~ "/exec/" ~ execId ~ "/start";
    Json config = Json(
      ["Detach": Json(false)]);
    auto response = doRequest("POST", path, config);

    if (!response.statusCode != 200) {
      enforce(false, "Failed to start exec: %d".format(response.statusCode));
    }
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
    int statusCode = 0; // For now, simplified implementation
    // In production, would need Unix socket support which requires low-level networking
    return ApiResponse(result, logText, 0);
  }
}
