/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.virtualization.resources;

import std.json : JSONValue;
import std.conv : to;

@safe:

/// Represents a virtual machine
struct VirtualMachine {
  string id;
  string name;
  string state;              // running, stopped, paused, crashed, dying, pmsuspended
  int vCpuCount;             // Number of virtual CPUs
  long memoryMB;             // Memory in MB
  long memoryUsedMB;         // Used memory in MB
  long cpuTimeNs;            // CPU time in nanoseconds
  string uuid;
  string hypervisorType;
  JSONValue config;

  this(JSONValue data) {
    if (auto id = "id" in data.object) id_data = id.str;
    if (auto name = "name" in data.object) this.name = name.str;
    if (auto state = "state" in data.object) this.state = state.str;
    if (auto vcpus = "vcpus" in data.object) this.vCpuCount = cast(int)vcpus.integer;
    if (auto memory = "memory" in data.object) this.memoryMB = memory.integer / 1024;
    if (auto uuid = "uuid" in data.object) this.uuid = uuid.str;
  }
}

/// Represents a virtual machine state
struct VMState {
  string name;
  string state;
  int vCpuCount;
  int maxVCpuCount;
  long memoryMB;
  long memoryUsedMB;
  long uptime;               // Seconds
  bool isPersistent;
  bool hasManagedSave;
  bool hasSnapshot;
  long cpu_time;

  this(JSONValue data) {
    if (auto name = "name" in data.object) this.name = name.str;
    if (auto state = "state" in data.object) this.state = state.str;
    if (auto vcpus = "active_vcpus" in data.object) this.vCpuCount = cast(int)vcpus.integer;
  }
}

/// Represents a virtual disk/volume
struct VirtualDisk {
  string id;
  string name;
  string path;
  string type;               // disk, cdrom, floppy
  string format;             // qcow2, raw, vmdk, etc.
  long sizeBytes;
  long usedBytes;
  bool readonly;
  string sourcePath;
  string targetDevice;       // hda, sda, vda, etc.

  this(JSONValue data) {
    if (auto id = "id" in data.object) id_data = id.str;
    if (auto name = "name" in data.object) this.name = name.str;
    if (auto path = "path" in data.object) this.path = path.str;
    if (auto type = "type" in data.object) this.type = type.str;
    if (auto format = "format" in data.object) this.format = format.str;
    if (auto size = "size" in data.object) this.sizeBytes = size.integer;
  }
}

/// Represents a virtual network interface
struct VirtualNIC {
  string id;
  string name;
  string macAddress;
  string networkName;
  string ipAddress;
  string ipv6Address;
  bool isActive;
  string type;               // network, bridge, user, etc.
  string model;              // virtio, e1000, etc.

  this(JSONValue data) {
    if (auto id = "id" in data.object) id_data = id.str;
    if (auto name = "name" in data.object) this.name = name.str;
    if (auto mac = "mac" in data.object) this.macAddress = mac.str;
    if (auto net = "network" in data.object) this.networkName = net.str;
    if (auto ip = "ip" in data.object) this.ipAddress = ip.str;
  }
}

/// Represents a virtual network
struct VirtualNetwork {
  string id;
  string name;
  string bridgeName;
  string[] forwardModes;     // nat, route, bridge, etc.
  bool isActive;
  bool isPersistent;
  string ipv4Network;        // e.g., "192.168.122.0/24"
  string ipv6Network;        // e.g., "fe80::/64"
  bool enableDhcp;
  JSONValue config;

  this(JSONValue data) {
    if (auto id = "id" in data.object) id_data = id.str;
    if (auto name = "name" in data.object) this.name = name.str;
    if (auto bridge = "bridge" in data.object) this.bridgeName = bridge.str;
    if (auto active = "active" in data.object) this.isActive = active.type == JSONValue.Type.true_;
  }
}

/// Represents a storage pool
struct StoragePool {
  string id;
  string name;
  string type;               // dir, disk, fs, lvm, iscsi, nfs, etc.
  string path;
  string target;
  long capacityBytes;
  long allocationBytes;
  long availableBytes;
  bool isActive;
  bool isPersistent;
  JSONValue config;

  this(JSONValue data) {
    if (auto id = "id" in data.object) id_data = id.str;
    if (auto name = "name" in data.object) this.name = name.str;
    if (auto type = "type" in data.object) this.type = type.str;
    if (auto path = "path" in data.object) this.path = path.str;
    if (auto capacity = "capacity" in data.object) this.capacityBytes = capacity.integer;
  }
}

/// Represents a storage volume
struct StorageVolume {
  string id;
  string name;
  string poolName;
  string type;               // file, block, dir, network
  string format;             // qcow2, raw, vmdk, etc.
  long sizeBytes;
  long allocationBytes;
  string path;
  JSONValue backingStore;    // For CoW volumes

  this(JSONValue data) {
    if (auto id = "id" in data.object) id_data = id.str;
    if (auto name = "name" in data.object) this.name = name.str;
    if (auto type = "type" in data.object) this.type = type.str;
    if (auto size = "size" in data.object) this.sizeBytes = size.integer;
  }
}

/// Represents a snapshot
struct Snapshot {
  string id;
  string name;
  string description;
  long createdAt;
  bool isCurrent;
  string vmName;
  long sizeBytes;
  JSONValue metadata;

  this(JSONValue data) {
    if (auto id = "id" in data.object) id_data = id.str;
    if (auto name = "name" in data.object) this.name = name.str;
    if (auto desc = "description" in data.object) this.description = desc.str;
    if (auto created = "created_at" in data.object) this.createdAt = created.integer;
  }
}

/// Represents VM performance metrics
struct VMMetrics {
  string vmName;
  long timestamp;
  int vCpuCount;
  double cpuUsagePercent;
  long memoryUsedBytes;
  long memoryAvailableBytes;
  long diskReadBytesPerSec;
  long diskWriteBytesPerSec;
  long networkInBytesPerSec;
  long networkOutBytesPerSec;
}

/// Represents hypervisor host capabilities
struct HostCapabilities {
  string hostname;
  int cpuCount;
  int cpuCoresPerSocket;
  int cpuThreadsPerCore;
  string cpuModel;
  long memoryBytes;
  long memoryFreeBytes;
  string[] supportedVirtTypes;
  string[] supportedHostModels;
  string hypervisorType;
  string hypervisorVersion;
}

/// Represents a VM clone configuration
struct CloneConfig {
  string sourceVMName;
  string targetVMName;
  bool snapshotParent;       // Use a snapshot for CoW
  bool resetMacAddresses;
  string[] diskFormats;      // Formats for cloned disks

  this(string source, string target) {
    this.sourceVMName = source;
    this.targetVMName = target;
    this.snapshotParent = false;
    this.resetMacAddresses = true;
  }
}

/// Represents VM migration information
struct MigrationInfo {
  string sourceHost;
  string targetHost;
  string vmName;
  bool liveFlag;
  bool persistAfterMigration;
  long estimatedTimeSec;
  string uri;                // Connection URI for target
}
