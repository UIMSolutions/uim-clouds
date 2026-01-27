/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.virtualbox.client;

import std.exception : enforce;
import std.format : format;
import std.json : JSONValue;

import vibe.http.client : requestHTTP;
import vibe.stream.operations : readAllUTF8;

import uim.virtualbox.config;
import uim.virtualbox.resources;

@trusted:

/// VirtualBox management client
class VirtualBoxClient {
  private VirtualBoxConfig config;

  this(VirtualBoxConfig config) {
    this.config = config;
  }

  /// Lists all registered VMs
  VBoxVM[] listVMs() {
    auto response = doRequest("GET", "/vms", JSONValue());
    enforce(response.statusCode == 200, format("Failed to list VMs: %d", response.statusCode));

    VBoxVM[] results;
    if (auto vms = "vms" in response.data.object) {
      if (vms.type == JSONValue.Type.array) {
        foreach (item; vms.array) {
          results ~= VBoxVM(item);
        }
      }
    }
    return results;
  }

  /// Gets details of a VM
  VBoxVM getVM(string nameOrId) {
    auto response = doRequest("GET", "/vms/" ~ nameOrId, JSONValue());
    enforce(response.statusCode == 200, format("Failed to get VM: %d", response.statusCode));
    return VBoxVM(response.data);
  }

  /// Creates a VM (registered but not provisioned)
  string createVM(string name, JSONValue settings) {
    JSONValue body = settings;
    body["name"] = JSONValue(name);
    auto response = doRequest("POST", "/vms", body);
    enforce(response.statusCode == 201, format("Failed to create VM: %d", response.statusCode));
    if (auto id = "id" in response.data.object) {
      return id.str;
    }
    return "";
  }

  /// Starts a VM
  void startVM(string nameOrId, bool headless = true) {
    string path = "/vms/" ~ nameOrId ~ "/start";
    if (headless) path ~= "?mode=headless";
    auto response = doRequest("POST", path, JSONValue());
    enforce(response.statusCode == 200, format("Failed to start VM: %d", response.statusCode));
  }

  /// Stops (ACPI shutdown) a VM
  void stopVM(string nameOrId) {
    auto response = doRequest("POST", "/vms/" ~ nameOrId ~ "/stop", JSONValue());
    enforce(response.statusCode == 200, format("Failed to stop VM: %d", response.statusCode));
  }

  /// Poweroff a VM
  void powerOffVM(string nameOrId) {
    auto response = doRequest("POST", "/vms/" ~ nameOrId ~ "/poweroff", JSONValue());
    enforce(response.statusCode == 200, format("Failed to power off VM: %d", response.statusCode));
  }

  /// Pause a VM
  void pauseVM(string nameOrId) {
    auto response = doRequest("POST", "/vms/" ~ nameOrId ~ "/pause", JSONValue());
    enforce(response.statusCode == 200, format("Failed to pause VM: %d", response.statusCode));
  }

  /// Resume a VM
  void resumeVM(string nameOrId) {
    auto response = doRequest("POST", "/vms/" ~ nameOrId ~ "/resume", JSONValue());
    enforce(response.statusCode == 200, format("Failed to resume VM: %d", response.statusCode));
  }

  /// Remove a VM
  void removeVM(string nameOrId, bool deleteDisks = false) {
    string path = "/vms/" ~ nameOrId;
    if (deleteDisks) path ~= "?deleteDisks=true";
    auto response = doRequest("DELETE", path, JSONValue());
    enforce(response.statusCode == 204, format("Failed to remove VM: %d", response.statusCode));
  }

  // Snapshot operations

  VBoxSnapshot[] listSnapshots(string nameOrId) {
    auto response = doRequest("GET", "/vms/" ~ nameOrId ~ "/snapshots", JSONValue());
    enforce(response.statusCode == 200, format("Failed to list snapshots: %d", response.statusCode));
    VBoxSnapshot[] results;
    if (auto snaps = "snapshots" in response.data.object) {
      if (snaps.type == JSONValue.Type.array) {
        foreach (item; snaps.array) {
          results ~= VBoxSnapshot(item);
        }
      }
    }
    return results;
  }

  string createSnapshot(string nameOrId, string snapshotName, string description = "") {
    JSONValue body = JSONValue(["name": JSONValue(snapshotName)]);
    if (description.length > 0) {
      body["description"] = JSONValue(description);
    }
    auto response = doRequest("POST", "/vms/" ~ nameOrId ~ "/snapshots", body);
    enforce(response.statusCode == 201, format("Failed to create snapshot: %d", response.statusCode));
    if (auto id = "id" in response.data.object) return id.str;
    return "";
  }

  void restoreSnapshot(string nameOrId, string snapshotName) {
    auto response = doRequest("POST", "/vms/" ~ nameOrId ~ "/snapshots/" ~ snapshotName ~ "/restore", JSONValue());
    enforce(response.statusCode == 200, format("Failed to restore snapshot: %d", response.statusCode));
  }

  void deleteSnapshot(string nameOrId, string snapshotName) {
    auto response = doRequest("DELETE", "/vms/" ~ nameOrId ~ "/snapshots/" ~ snapshotName, JSONValue());
    enforce(response.statusCode == 204, format("Failed to delete snapshot: %d", response.statusCode));
  }

  // Storage attachments

  VBoxStorageAttachment[] listStorage(string nameOrId) {
    auto response = doRequest("GET", "/vms/" ~ nameOrId ~ "/storage", JSONValue());
    enforce(response.statusCode == 200, format("Failed to list storage: %d", response.statusCode));
    VBoxStorageAttachment[] results;
    if (auto items = "attachments" in response.data.object) {
      if (items.type == JSONValue.Type.array) {
        foreach (item; items.array) {
          results ~= VBoxStorageAttachment(item);
        }
      }
    }
    return results;
  }

  void attachStorage(string nameOrId, JSONValue attachment) {
    auto response = doRequest("POST", "/vms/" ~ nameOrId ~ "/storage", attachment);
    enforce(response.statusCode == 200, format("Failed to attach storage: %d", response.statusCode));
  }

  void detachStorage(string nameOrId, string port, string device) {
    auto response = doRequest("DELETE", "/vms/" ~ nameOrId ~ "/storage/" ~ port ~ "/" ~ device, JSONValue());
    enforce(response.statusCode == 204, format("Failed to detach storage: %d", response.statusCode));
  }

  // Network adapters

  VBoxNIC[] listNICs(string nameOrId) {
    auto response = doRequest("GET", "/vms/" ~ nameOrId ~ "/nics", JSONValue());
    enforce(response.statusCode == 200, format("Failed to list NICs: %d", response.statusCode));
    VBoxNIC[] results;
    if (auto items = "nics" in response.data.object) {
      if (items.type == JSONValue.Type.array) {
        foreach (item; items.array) {
          results ~= VBoxNIC(item);
        }
      }
    }
    return results;
  }

  void attachNIC(string nameOrId, JSONValue nicConfig) {
    auto response = doRequest("POST", "/vms/" ~ nameOrId ~ "/nics", nicConfig);
    enforce(response.statusCode == 200, format("Failed to attach NIC: %d", response.statusCode));
  }

  void detachNIC(string nameOrId, string slot) {
    auto response = doRequest("DELETE", "/vms/" ~ nameOrId ~ "/nics/" ~ slot, JSONValue());
    enforce(response.statusCode == 204, format("Failed to detach NIC: %d", response.statusCode));
  }

  // Host info

  VBoxHostInfo getHostInfo() {
    auto response = doRequest("GET", "/host", JSONValue());
    enforce(response.statusCode == 200, format("Failed to get host info: %d", response.statusCode));
    VBoxHostInfo info;
    // Populate fields if present
    if (auto name = "hostname" in response.data.object) info.hostName = name.str;
    if (auto cpus = "cpus" in response.data.object) info.cpuCount = cast(int)cpus.integer;
    if (auto mem = "memory" in response.data.object) info.memoryMB = mem.integer;
    if (auto ver = "version" in response.data.object) info.vboxVersion = ver.str;
    return info;
  }

  // Private helper

  private struct HttpResponse {
    int statusCode;
    JSONValue data;
  }

  private HttpResponse doRequest(string method, string path, JSONValue body_) @system {
    // Placeholder for actual VBoxManage or web service call
    HttpResponse response;
    response.statusCode = 200;
    response.data = JSONValue();
    return response;
  }
}
