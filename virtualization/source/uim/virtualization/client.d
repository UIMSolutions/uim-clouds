/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.virtualization.client;

import uim.virtualization;

@trusted:

/// Virtualization management client
class VirtualizationClient {
  private string endpoint;
  private HypervisorType hypervisor;
  private string apiVersion;
  private string username;
  private string password;
  private bool useLibvirt;
  private int connectionTimeout;

  this(
    string endpoint,
    HypervisorType hypervisor = HypervisorType.KVM,
    string apiVersion = "v1.0",
    bool useLibvirt = true,
    int timeout = 30
  ) {
    this.endpoint = endpoint;
    this.hypervisor = hypervisor;
    this.apiVersion = apiVersion;
    this.useLibvirt = useLibvirt;
    this.connectionTimeout = timeout;
  }

  this(VirtualizationConfig config) {
    this.endpoint = config.endpoint;
    this.hypervisor = config.hypervisor;
    this.apiVersion = config.apiVersion;
    this.username = config.username;
    this.password = config.password;
    this.useLibvirt = config.useLibvirt;
    this.connectionTimeout = config.connectionTimeout;
  }

  // Virtual Machine operations

  /// Lists all virtual machines
  VirtualMachine[] listVirtualMachines(bool includeInactive = false) {
    string path = "/domains";
    if (includeInactive) {
      path ~= "?includeInactive=true";
    }
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list VMs: %d", response.statusCode));

    VirtualMachine[] results;
    if (auto domains = "domains" in response.data.object) {
      if (domains.isArray) {
        foreach (item; domains.array) {
          results ~= VirtualMachine(item);
        }
      }
    }
    return results;
  }

  /// Gets information about a specific VM
  VirtualMachine getVirtualMachine(string nameOrId) {
    string path = "/domains/" ~ nameOrId;
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to get VM: %d", response.statusCode));
    return VirtualMachine(response.data);
  }

  /// Gets detailed state of a VM
  VMState getVirtualMachineState(string nameOrId) {
    string path = "/domains/" ~ nameOrId ~ "/state";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to get VM state: %d", response.statusCode));
    return VMState(response.data);
  }

  /// Creates a new virtual machine
  string createVirtualMachine(string name, Json config) {
    string path = "/domains";
    config["name"] = Json(name);
    auto response = doRequest("POST", path, config);
    enforce(response.statusCode == 201, format("Failed to create VM: %d", response.statusCode));
    
    if (auto id = "id" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  /// Starts a virtual machine
  void startVirtualMachine(string nameOrId) {
    string path = "/domains/" ~ nameOrId ~ "/start";
    auto response = doRequest("POST", path, Json());
    enforce(response.statusCode == 200, format("Failed to start VM: %d", response.statusCode));
  }

  /// Stops a virtual machine
  void stopVirtualMachine(string nameOrId, bool force = false) {
    string path = "/domains/" ~ nameOrId ~ "/stop";
    if (force) path ~= "?force=true";
    auto response = doRequest("POST", path, Json());
    enforce(response.statusCode == 200, format("Failed to stop VM: %d", response.statusCode));
  }

  /// Reboots a virtual machine
  void rebootVirtualMachine(string nameOrId, bool force = false) {
    string path = "/domains/" ~ nameOrId ~ "/reboot";
    if (force) path ~= "?force=true";
    auto response = doRequest("POST", path, Json());
    enforce(response.statusCode == 200, format("Failed to reboot VM: %d", response.statusCode));
  }

  /// Pauses a virtual machine
  void pauseVirtualMachine(string nameOrId) {
    string path = "/domains/" ~ nameOrId ~ "/pause";
    auto response = doRequest("POST", path, Json());
    enforce(response.statusCode == 200, format("Failed to pause VM: %d", response.statusCode));
  }

  /// Resumes a paused virtual machine
  void resumeVirtualMachine(string nameOrId) {
    string path = "/domains/" ~ nameOrId ~ "/resume";
    auto response = doRequest("POST", path, Json());
    enforce(response.statusCode == 200, format("Failed to resume VM: %d", response.statusCode));
  }

  /// Destroys (deletes) a virtual machine
  void destroyVirtualMachine(string nameOrId, bool deleteStorage = false) {
    string path = "/domains/" ~ nameOrId;
    if (deleteStorage) path ~= "?deleteStorage=true";
    auto response = doRequest("DELETE", path, Json());
    enforce(response.statusCode == 204, format("Failed to destroy VM: %d", response.statusCode));
  }

  // Disk operations

  /// Lists disks attached to a VM
  VirtualDisk[] listVirtualDisks(string vmNameOrId) {
    string path = "/domains/" ~ vmNameOrId ~ "/disks";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list disks: %d", response.statusCode));

    VirtualDisk[] results;
    if (auto disks = "disks" in response.data.object) {
      if (disks.isArray) {
        foreach (item; disks.array) {
          results ~= VirtualDisk(item);
        }
      }
    }
    return results;
  }

  /// Attaches a disk to a VM
  void attachDisk(string vmNameOrId, Json diskConfig) {
    string path = "/domains/" ~ vmNameOrId ~ "/disks";
    auto response = doRequest("POST", path, diskConfig);
    enforce(response.statusCode == 200, format("Failed to attach disk: %d", response.statusCode));
  }

  /// Detaches a disk from a VM
  void detachDisk(string vmNameOrId, string diskTargetDevice) {
    string path = "/domains/" ~ vmNameOrId ~ "/disks/" ~ diskTargetDevice;
    auto response = doRequest("DELETE", path, Json());
    enforce(response.statusCode == 204, format("Failed to detach disk: %d", response.statusCode));
  }

  // Network interface operations

  /// Lists network interfaces attached to a VM
  VirtualNIC[] listVirtualNICs(string vmNameOrId) {
    string path = "/domains/" ~ vmNameOrId ~ "/interfaces";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list NICs: %d", response.statusCode));

    VirtualNIC[] results;
    if (auto nics = "interfaces" in response.data.object) {
      if (nics.isArray) {
        foreach (item; nics.array) {
          results ~= VirtualNIC(item);
        }
      }
    }
    return results;
  }

  /// Attaches a network interface to a VM
  void attachNIC(string vmNameOrId, Json nicConfig) {
    string path = "/domains/" ~ vmNameOrId ~ "/interfaces";
    auto response = doRequest("POST", path, nicConfig);
    enforce(response.statusCode == 200, format("Failed to attach NIC: %d", response.statusCode));
  }

  /// Detaches a network interface from a VM
  void detachNIC(string vmNameOrId, string macAddress) {
    string path = "/domains/" ~ vmNameOrId ~ "/interfaces/" ~ macAddress;
    auto response = doRequest("DELETE", path, Json());
    enforce(response.statusCode == 204, format("Failed to detach NIC: %d", response.statusCode));
  }

  // Snapshot operations

  /// Lists snapshots for a VM
  Snapshot[] listSnapshots(string vmNameOrId) {
    string path = "/domains/" ~ vmNameOrId ~ "/snapshots";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list snapshots: %d", response.statusCode));

    Snapshot[] results;
    if (auto snapshots = "snapshots" in response.data.object) {
      if (snapshots.isArray) {
        foreach (item; snapshots.array) {
          results ~= Snapshot(item);
        }
      }
    }
    return results;
  }

  /// Creates a snapshot of a VM
  string createSnapshot(string vmNameOrId, string snapshotName, string description = "") {
    string path = "/domains/" ~ vmNameOrId ~ "/snapshots";
    Json config = Json(["name": Json(snapshotName)]);
    if (description.length > 0) {
      config["description"] = Json(description);
    }
    auto response = doRequest("POST", path, config);
    enforce(response.statusCode == 201, format("Failed to create snapshot: %d", response.statusCode));
    
    if (auto id = "id" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  /// Reverts a VM to a snapshot
  void revertToSnapshot(string vmNameOrId, string snapshotName) {
    string path = "/domains/" ~ vmNameOrId ~ "/snapshots/" ~ snapshotName ~ "/revert";
    auto response = doRequest("POST", path, Json());
    enforce(response.statusCode == 200, format("Failed to revert snapshot: %d", response.statusCode));
  }

  /// Deletes a snapshot
  void deleteSnapshot(string vmNameOrId, string snapshotName) {
    string path = "/domains/" ~ vmNameOrId ~ "/snapshots/" ~ snapshotName;
    auto response = doRequest("DELETE", path, Json());
    enforce(response.statusCode == 204, format("Failed to delete snapshot: %d", response.statusCode));
  }

  // Storage operations

  /// Lists storage pools
  StoragePool[] listStoragePools(bool includeInactive = false) {
    string path = "/storagePools";
    if (includeInactive) path ~= "?includeInactive=true";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list storage pools: %d", response.statusCode));

    StoragePool[] results;
    if (auto pools = "pools" in response.data.object) {
      if (pools.isArray) {
        foreach (item; pools.array) {
          results ~= StoragePool(item);
        }
      }
    }
    return results;
  }

  /// Gets information about a storage pool
  StoragePool getStoragePool(string poolName) {
    string path = "/storagePools/" ~ poolName;
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to get storage pool: %d", response.statusCode));
    return StoragePool(response.data);
  }

  /// Creates a storage pool
  string createStoragePool(string poolName, Json config) {
    string path = "/storagePools";
    config["name"] = Json(poolName);
    auto response = doRequest("POST", path, config);
    enforce(response.statusCode == 201, format("Failed to create storage pool: %d", response.statusCode));
    
    if (auto id = "id" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  /// Deletes a storage pool
  void deleteStoragePool(string poolName) {
    string path = "/storagePools/" ~ poolName;
    auto response = doRequest("DELETE", path, Json());
    enforce(response.statusCode == 204, format("Failed to delete storage pool: %d", response.statusCode));
  }

  /// Lists volumes in a storage pool
  StorageVolume[] listStorageVolumes(string poolName) {
    string path = "/storagePools/" ~ poolName ~ "/volumes";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list storage volumes: %d", response.statusCode));

    StorageVolume[] results;
    if (auto volumes = "volumes" in response.data.object) {
      if (volumes.type == Json.Type.array) {
        foreach (item; volumes.array) {
          results ~= StorageVolume(item);
        }
      }
    }
    return results;
  }

  /// Creates a storage volume
  string createStorageVolume(string poolName, Json volumeConfig) {
    string path = "/storagePools/" ~ poolName ~ "/volumes";
    auto response = doRequest("POST", path, volumeConfig);
    enforce(response.statusCode == 201, format("Failed to create volume: %d", response.statusCode));
    
    if (auto id = "id" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  /// Deletes a storage volume
  void deleteStorageVolume(string poolName, string volumeName) {
    string path = "/storagePools/" ~ poolName ~ "/volumes/" ~ volumeName;
    auto response = doRequest("DELETE", path, Json());
    enforce(response.statusCode == 204, format("Failed to delete volume: %d", response.statusCode));
  }

  // Network operations

  /// Lists virtual networks
  VirtualNetwork[] listVirtualNetworks(bool includeInactive = false) {
    string path = "/networks";
    if (includeInactive) path ~= "?includeInactive=true";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to list networks: %d", response.statusCode));

    VirtualNetwork[] results;
    if (auto networks = "networks" in response.data.object) {
      if (networks.type == Json.Type.array) {
        foreach (item; networks.array) {
          results ~= VirtualNetwork(item);
        }
      }
    }
    return results;
  }

  /// Gets information about a virtual network
  VirtualNetwork getVirtualNetwork(string networkName) {
    string path = "/networks/" ~ networkName;
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to get network: %d", response.statusCode));
    return VirtualNetwork(response.data);
  }

  /// Creates a virtual network
  string createVirtualNetwork(string networkName, Json config) {
    string path = "/networks";
    config["name"] = Json(networkName);
    auto response = doRequest("POST", path, config);
    enforce(response.statusCode == 201, format("Failed to create network: %d", response.statusCode));
    
    if (auto id = "id" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  /// Deletes a virtual network
  void deleteVirtualNetwork(string networkName) {
    string path = "/networks/" ~ networkName;
    auto response = doRequest("DELETE", path, Json());
    enforce(response.statusCode == 204, format("Failed to delete network: %d", response.statusCode));
  }

  // Cloning and migration

  /// Clones a virtual machine
  string cloneVirtualMachine(CloneConfig config) {
    Json requestBody = Json([
      "sourceVMName": Json(config.sourceVMName),
      "targetVMName": Json(config.targetVMName),
      "snapshotParent": Json(config.snapshotParent),
      "resetMacAddresses": Json(config.resetMacAddresses)
    ]);
    
    string path = "/domains/clone";
    auto response = doRequest("POST", path, requestBody);
    enforce(response.statusCode == 201, format("Failed to clone VM: %d", response.statusCode));
    
    if (auto id = "id" in response.data.object) {
      return id.toString;
    }
    return "";
  }

  /// Migrates a VM to another host
  void migrateVirtualMachine(MigrationInfo migrationInfo) {
    Json requestBody = Json([
      "targetUri": Json(migrationInfo.uri),
      "live": Json(migrationInfo.liveFlag),
      "persistAfterMigration": Json(migrationInfo.persistAfterMigration)
    ]);
    
    string path = "/domains/" ~ migrationInfo.vmName ~ "/migrate";
    auto response = doRequest("POST", path, requestBody);
    enforce(response.statusCode == 202, format("Failed to migrate VM: %d", response.statusCode));
  }

  // Host information

  /// Gets host capabilities
  HostCapabilities getHostCapabilities() {
    string path = "/capabilities";
    auto response = doRequest("GET", path, Json());
    enforce(response.statusCode == 200, format("Failed to get capabilities: %d", response.statusCode));
    
    HostCapabilities caps;
    // Parse capabilities from response
    return caps;
  }

  // Private helper methods

  private struct HttpResponse {
    int statusCode;
    Json data;
  }

  private HttpResponse doRequest(string method, string path, Json body_) @system {
    // This would be implemented with actual HTTP calls
    // For now, this is a placeholder that shows the structure
    HttpResponse response;
    response.statusCode = 200;
    response.data = Json();
    return response;
  }
}
