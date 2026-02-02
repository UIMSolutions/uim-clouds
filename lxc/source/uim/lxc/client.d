/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.lxc.client;

import std.exception : enforce;
import std.format : format;
import std.json : Json, parseJSON;
import std.toStringing : split;

import vibe.http.client : HTTPClientRequest, HTTPClientResponse, requestHTTP;
import vibe.toStringeam.operations : readAllUTF8;

import uim.lxc.config;
import uim.lxc.resources;

@trusted:

/// LXC API HTTP client.
class LXCClient {
  private string endpoint;
  private string apiVersion;
  private bool insecureSkipVerify;
  private string caCertPath;
  private string certificatePath;
  private string keyPath;

  this(
    string endpoint,
    string apiVersion = "v1.0",
    bool insecureSkipVerify = false,
    string caCertPath = "",
    string certificatePath = "",
    string keyPath = ""
  ) {
    this.endpoint = endpoint;
    this.apiVersion = apiVersion;
    this.insecureSkipVerify = insecureSkipVerify;
    this.caCertPath = caCertPath;
    this.certificatePath = certificatePath;
    this.keyPath = keyPath;
  }

  this(LXCConfig config) {
    this.endpoint = config.endpoint;
    this.apiVersion = config.apiVersion;
    this.insecureSkipVerify = config.insecureSkipVerify;
    this.caCertPath = config.caCertPath;
    this.certificatePath = config.certificatePath;
    this.keyPath = config.keyPath;
  }

  // Container operations

  /// Lists all containers.
  Container[] listContainers() {
    string path = "/" ~ apiVersion ~ "/containers";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list containers: %d", response.statusCode));

    Container[] results;
    if (auto metadata = "metadata" in response.data.object) {
      if (metadata.type == Json.Type.array) {
        foreach (item; metadata.array) {
          results ~= Container(item);
        }
      }
    }
    return results;
  }

  /// Gets a single container by name.
  Container getContainer(string name) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ name;
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to get container %s: %d", name, response.statusCode));
    
    if (auto metadata = "metadata" in response.data.object) {
      return Container(metadata);
    }
    return Container(response.data);
  }

  /// Gets detailed container state.
  ContainerState getContainerState(string name) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ name ~ "/state";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to get container state: %d", response.statusCode));
    
    if (auto metadata = "metadata" in response.data.object) {
      return ContainerState(metadata);
    }
    return ContainerState(response.data);
  }

  /// Creates a new container.
  string createContainer(string name, Json config) {
    string path = "/" ~ apiVersion ~ "/containers";
    config["name"] = Json(name);
    auto response = doRequest("POST", path, config);
    enforce(response.statusCode == 202, format("Failed to create container: %d", response.statusCode));
    
    if (auto id = "operation" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  /// Starts a container.
  string startContainer(string name, bool force = false) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ name ~ "/state";
    Json config = Json(["action": Json("start"), "timeout": Json(30)]);
    if (force) {
      config["force"] = Json(true);
    }
    auto response = doRequest("PUT", path, config);
    enforce(response.statusCode == 202, format("Failed to start container: %d", response.statusCode));
    
    if (auto id = "operation" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  /// Stops a container.
  string stopContainer(string name, int timeout = 30, bool force = false) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ name ~ "/state";
    Json config = Json([
      "action": Json("stop"),
      "timeout": Json(timeout)
    ]);
    if (force) {
      config["force"] = Json(true);
    }
    auto response = doRequest("PUT", path, config);
    enforce(response.statusCode == 202, format("Failed to stop container: %d", response.statusCode));
    
    if (auto id = "operation" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  /// Restarts a container.
  string restartContainer(string name, int timeout = 30) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ name ~ "/state";
    Json config = Json(["action": Json("restart"), "timeout": Json(timeout)]);
    auto response = doRequest("PUT", path, config);
    enforce(response.statusCode == 202, format("Failed to restart container: %d", response.statusCode));
    
    if (auto id = "operation" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  /// Freezes a container.
  string freezeContainer(string name) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ name ~ "/state";
    Json config = Json(["action": Json("freeze")]);
    auto response = doRequest("PUT", path, config);
    enforce(response.statusCode == 202, format("Failed to freeze container: %d", response.statusCode));
    
    if (auto id = "operation" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  /// Unfreezes a container.
  string unfreezeContainer(string name) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ name ~ "/state";
    Json config = Json(["action": Json("unfreeze")]);
    auto response = doRequest("PUT", path, config);
    enforce(response.statusCode == 202, format("Failed to unfreeze container: %d", response.statusCode));
    
    if (auto id = "operation" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  /// Removes a container.
  string removeContainer(string name, bool force = false) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ name;
    auto response = doRequest("DELETE", path, Json());
    enforce(response.statusCode == 202, format("Failed to remove container: %d", response.statusCode));
    
    if (auto id = "operation" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  /// Gets container logs.
  LogsResponse getContainerLogs(string name) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ name ~ "/logs";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to get container logs: %d", response.statusCode));
    return LogsResponse(response.rawOutput);
  }

  // Image/Template operations

  /// Lists all available images or templates.
  Image[] listImages() {
    string path = "/" ~ apiVersion ~ "/images";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list images: %d", response.statusCode));

    Image[] results;
    if (auto metadata = "metadata" in response.data.object) {
      if (metadata.type == Json.Type.array) {
        foreach (item; metadata.array) {
          results ~= Image(item);
        }
      }
    }
    return results;
  }

  /// Gets information about an image.
  Image getImage(string fingerprint) {
    string path = "/" ~ apiVersion ~ "/images/" ~ fingerprint;
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to get image: %d", response.statusCode));
    
    if (auto metadata = "metadata" in response.data.object) {
      return Image(metadata);
    }
    return Image(response.data);
  }

  // Network operations

  /// Lists all networks.
  Network[] listNetworks() {
    string path = "/" ~ apiVersion ~ "/networks";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list networks: %d", response.statusCode));

    Network[] results;
    if (auto metadata = "metadata" in response.data.object) {
      if (metadata.type == Json.Type.array) {
        foreach (item; metadata.array) {
          results ~= Network(item);
        }
      }
    }
    return results;
  }

  /// Gets information about a network.
  Network getNetwork(string name) {
    string path = "/" ~ apiVersion ~ "/networks/" ~ name;
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to get network: %d", response.statusCode));
    
    if (auto metadata = "metadata" in response.data.object) {
      return Network(metadata);
    }
    return Network(response.data);
  }

  /// Creates a network.
  string createNetwork(string name, Json config) {
    string path = "/" ~ apiVersion ~ "/networks";
    config["name"] = Json(name);
    auto response = doRequest("POST", path, config);
    enforce(response.statusCode == 202, format("Failed to create network: %d", response.statusCode));
    
    if (auto id = "operation" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  /// Removes a network.
  string removeNetwork(string name) {
    string path = "/" ~ apiVersion ~ "/networks/" ~ name;
    auto response = doRequest("DELETE", path, Json());
    enforce(response.statusCode == 202, format("Failed to remove network: %d", response.statusCode));
    
    if (auto id = "operation" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  // Storage operations

  /// Lists all storage pools.
  StoragePool[] listStoragePools() {
    string path = "/" ~ apiVersion ~ "/storage-pools";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list storage pools: %d", response.statusCode));

    StoragePool[] results;
    if (auto metadata = "metadata" in response.data.object) {
      if (metadata.type == Json.Type.array) {
        foreach (item; metadata.array) {
          results ~= StoragePool(item);
        }
      }
    }
    return results;
  }

  /// Gets storage pool information.
  StoragePool getStoragePool(string name) {
    string path = "/" ~ apiVersion ~ "/storage-pools/" ~ name;
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to get storage pool: %d", response.statusCode));
    
    if (auto metadata = "metadata" in response.data.object) {
      return StoragePool(metadata);
    }
    return StoragePool(response.data);
  }

  /// Creates a storage pool.
  string createStoragePool(string name, Json config) {
    string path = "/" ~ apiVersion ~ "/storage-pools";
    config["name"] = Json(name);
    auto response = doRequest("POST", path, config);
    enforce(response.statusCode == 202, format("Failed to create storage pool: %d", response.statusCode));
    
    if (auto id = "operation" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  /// Removes a storage pool.
  string removeStoragePool(string name) {
    string path = "/" ~ apiVersion ~ "/storage-pools/" ~ name;
    auto response = doRequest("DELETE", path, Json());
    enforce(response.statusCode == 202, format("Failed to remove storage pool: %d", response.statusCode));
    
    if (auto id = "operation" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  // Snapshot operations

  /// Lists snapshots for a container.
  Snapshot[] listSnapshots(string containerName) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ containerName ~ "/snapshots";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list snapshots: %d", response.statusCode));

    Snapshot[] results;
    if (auto metadata = "metadata" in response.data.object) {
      if (metadata.type == Json.Type.array) {
        foreach (item; metadata.array) {
          results ~= Snapshot(item);
        }
      }
    }
    return results;
  }

  /// Creates a snapshot of a container.
  string createSnapshot(string containerName, string snapshotName, string description = "") {
    string path = "/" ~ apiVersion ~ "/containers/" ~ containerName ~ "/snapshots";
    Json config = Json(["name": Json(snapshotName)]);
    if (description.length > 0) {
      config["description"] = Json(description);
    }
    auto response = doRequest("POST", path, config);
    enforce(response.statusCode == 202, format("Failed to create snapshot: %d", response.statusCode));
    
    if (auto id = "operation" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  /// Removes a snapshot.
  string removeSnapshot(string containerName, string snapshotName) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ containerName ~ "/snapshots/" ~ snapshotName;
    auto response = doRequest("DELETE", path, Json());
    enforce(response.statusCode == 202, format("Failed to remove snapshot: %d", response.statusCode));
    
    if (auto id = "operation" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  /// Restores a container to a snapshot.
  string restoreSnapshot(string containerName, string snapshotName) {
    string path = "/" ~ apiVersion ~ "/containers/" ~ containerName ~ "/snapshots/" ~ snapshotName ~ "/restore";
    auto response = doRequest("POST", path, Json());
    enforce(response.statusCode == 202, format("Failed to restore snapshot: %d", response.statusCode));
    
    if (auto id = "operation" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  // Operation monitoring

  /// Gets operation status.
  Operation getOperation(string operationId) {
    string path = "/" ~ apiVersion ~ "/operations/" ~ operationId;
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to get operation: %d", response.statusCode));
    
    if (auto metadata = "metadata" in response.data.object) {
      return Operation(metadata);
    }
    return Operation(response.data);
  }

  /// Waits for an operation to complete.
  bool waitOperation(string operationId, int timeout = 300) {
    string path = "/" ~ apiVersion ~ "/operations/" ~ operationId ~ "/wait?timeout=" ~ format("%d", timeout);
    auto response = doRequest("GET", path, Json());
    return response.statusCode == 200;
  }

  // Private helper methods

  private struct HttpResponse {
    int statusCode;
    Json data;
    string rawOutput;
  }

  private HttpResponse doRequest(string method, string path, Json body_) @system {
    // This would be implemented with actual HTTP calls
    // For now, this is a placeholder that shows the structure
    HttpResponse response;
    response.statusCode = 200;
    response.data = Json();
    response.rawOutput = "";
    return response;
  }
}
