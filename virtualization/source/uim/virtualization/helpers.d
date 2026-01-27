/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.virtualization.helpers;

import std.json : Json;
import std.conv : to;
import std.format : format;

import uim.virtualization.resources;
import uim.virtualization.config;

@safe:

/// Creates a basic VM configuration
Json createVMConfig(
  string name,
  int vcpuCount = 2,
  long memoryMB = 2048,
  string osType = "linux"
) {
  Json config = Json([
    "name": Json(name),
    "memory": Json(memoryMB),
    "vcpus": Json(vcpuCount),
    "os": Json(["type": Json(osType)])
  ]);
  return config;
}

/// Creates a VM disk configuration
Json createVMDiskConfig(
  string sourcePath,
  string targetDevice = "vda",
  string type = "disk",
  string format = "qcow2",
  bool readonly = false
) {
  Json config = Json([
    "type": Json(type),
    "source": Json(sourcePath),
    "target": Json(targetDevice),
    "format": Json(format),
    "readonly": Json(readonly)
  ]);
  return config;
}

/// Creates a VM network interface configuration
Json createVMNICConfig(
  string networkName,
  string model = "virtio",
  string macAddress = ""
) {
  Json config = Json([
    "type": Json("network"),
    "network": Json(networkName),
    "model": Json(model)
  ]);
  
  if (macAddress.length > 0) {
    config["mac"] = Json(macAddress);
  }
  
  return config;
}

/// Creates a bridged network interface configuration
Json createBridgedNICConfig(
  string bridgeName,
  string model = "virtio",
  string macAddress = ""
) {
  Json config = Json([
    "type": Json("bridge"),
    "source": Json(bridgeName),
    "model": Json(model)
  ]);
  
  if (macAddress.length > 0) {
    config["mac"] = Json(macAddress);
  }
  
  return config;
}

/// Creates a NAT network configuration
Json createNATNetworkConfig(
  string networkName,
  string ipv4Network = "192.168.122.0/24",
  bool enableDhcp = true
) {
  Json config = Json([
    "name": Json(networkName),
    "forward": Json(["mode": Json("nat")]),
    "bridge": Json(["name": Json("virbr0")]),
    "ip": Json([
      "address": Json("192.168.122.1"),
      "netmask": Json("255.255.255.0")
    ])
  ]);
  
  if (enableDhcp) {
    config["dhcp"] = Json([
      "start": Json("192.168.122.2"),
      "end": Json("192.168.122.254")
    ]);
  }
  
  return config;
}

/// Creates a bridged network configuration
Json createBridgedNetworkConfig(
  string networkName,
  string bridgeName = "br0",
  string bridgeType = "bridge"
) {
  Json config = Json([
    "name": Json(networkName),
    "forward": Json(["mode": Json("bridge")]),
    "bridge": Json([
      "name": Json(bridgeName),
      "type": Json(bridgeType)
    ])
  ]);
  
  return config;
}

/// Creates a storage pool configuration for directory-based storage
Json createDirStoragePoolConfig(
  string poolName,
  string path
) {
  Json config = Json([
    "name": Json(poolName),
    "type": Json("dir"),
    "target": Json(["path": Json(path)])
  ]);
  return config;
}

/// Creates a storage pool configuration for logical volume management
Json createLVMStoragePoolConfig(
  string poolName,
  string volumeGroup,
  string targetPath = "/dev"
) {
  Json config = Json([
    "name": Json(poolName),
    "type": Json("logical"),
    "source": Json(["name": Json(volumeGroup)]),
    "target": Json(["path": Json(targetPath ~ "/" ~ volumeGroup)])
  ]);
  return config;
}

/// Creates a storage volume configuration
Json createStorageVolumeConfig(
  string volumeName,
  long sizeBytes,
  string format = "qcow2"
) {
  Json config = Json([
    "name": Json(volumeName),
    "capacity": Json(sizeBytes),
    "format": Json(["type": Json(format)])
  ]);
  return config;
}

/// Creates a storage volume from a backing store (CoW)
Json createCowVolumeConfig(
  string volumeName,
  string backingStorePath,
  long sizeBytes = 0
) {
  Json config = Json([
    "name": Json(volumeName),
    "backingStore": Json(["path": Json(backingStorePath), "format": Json("qcow2")])
  ]);
  
  if (sizeBytes > 0) {
    config["capacity"] = Json(sizeBytes);
  }
  
  return config;
}

/// Creates CPU configuration for a VM
Json createVMCPUConfig(
  int vCpuCount,
  string model = "host-passthrough",
  int sockets = 1,
  int cores = 2,
  int threads = 1
) {
  Json config = Json([
    "vcpus": Json(vCpuCount),
    "cpu": Json([
      "model": Json(model),
      "topology": Json([
        "sockets": Json(sockets),
        "cores": Json(cores),
        "threads": Json(threads)
      ])
    ])
  ]);
  return config;
}

/// Creates memory configuration for a VM
Json createVMMemoryConfig(
  long memoryMB,
  long maxMemoryMB = 0
) {
  Json config = Json([
    "memory": Json(memoryMB),
    "unit": Json("MiB")
  ]);
  
  if (maxMemoryMB > 0) {
    config["maxMemory"] = Json(maxMemoryMB);
  }
  
  return config;
}

/// Creates console/serial port configuration
Json createConsoleConfig(
  string type = "pty",
  int targetPort = 0
) {
  Json config = Json([
    "type": Json(type),
    "target": Json(["port": Json(targetPort)])
  ]);
  return config;
}

/// Creates UEFI/BIOS boot configuration
Json createBootConfig(
  string firmware = "bios",
  string[] bootDevices = null
) {
  Json config = Json([
    "firmware": Json(firmware)
  ]);
  
  if (bootDevices && bootDevices.length > 0) {
    Json[] bootOrder;
    foreach (device; bootDevices) {
      bootOrder ~= Json(["dev": Json(device)]);
    }
    config["bootOrder"] = Json(bootOrder);
  }
  
  return config;
}

/// Creates a complete KVM/QEMU VM template
Json createKVMVMTemplate(
  string name,
  int vcpuCount = 4,
  long memoryMB = 4096,
  string diskPath = "",
  string networkName = "default",
  string osType = "linux"
) {
  Json config = createVMConfig(name, vcpuCount, memoryMB, osType);
  
  // Add disk if provided
  if (diskPath.length > 0) {
    Json[] disks;
    disks ~= createVMDiskConfig(diskPath, "vda", "disk", "qcow2");
    config["devices"] = Json(["disk": Json(disks)]);
  }
  
  // Add network interface
  Json[] nics;
  nics ~= createVMNICConfig(networkName);
  config["devices"]["interface"] = Json(nics);
  
  // Add console
  config["devices"]["console"] = Json([createConsoleConfig()]);
  
  // Add boot configuration
  config["boot"] = Json(createBootConfig("bios", ["disk", "cdrom"]));
  
  return config;
}

/// Creates a container-like lightweight VM
Json createLightweightVMTemplate(
  string name,
  long memoryMB = 512,
  int vcpuCount = 1
) {
  return createVMConfig(name, vcpuCount, memoryMB, "linux");
}

/// Merges two VM configurations
Json mergeVMConfigs(Json baseConfig, Json additionalConfig) {
  Json result = baseConfig;
  
  if (additionalConfig.type == Json.Type.object) {
    foreach (key, value; additionalConfig.object) {
      result[key] = value;
    }
  }
  
  return result;
}

/// Creates clone configuration
CloneConfig createCloneConfig(
  string sourceVM,
  string targetVM,
  bool useSnapshot = false,
  bool resetMac = true
) {
  CloneConfig config = CloneConfig(sourceVM, targetVM);
  config.snapshotParent = useSnapshot;
  config.resetMacAddresses = resetMac;
  return config;
}

/// Creates migration information
MigrationInfo createMigrationInfo(
  string vmName,
  string sourceHost,
  string targetHost,
  string targetUri,
  bool liveFlag = true
) {
  MigrationInfo info;
  info.vmName = vmName;
  info.sourceHost = sourceHost;
  info.targetHost = targetHost;
  info.uri = targetUri;
  info.liveFlag = liveFlag;
  info.persistAfterMigration = true;
  return info;
}

/// Generates a MAC address
string generateMACAddress() @safe {
  // Simple MAC generation (52:54:00 is the libvirt default prefix)
  return "52:54:00:aa:bb:cc";
}

/// Converts memory from human-readable format to MB
long parseMemoryString(string memStr) @safe {
  if (memStr.endsWith("GB")) {
    return to!long(memStr[0 .. $ - 2]) * 1024;
  }
  if (memStr.endsWith("MB")) {
    return to!long(memStr[0 .. $ - 2]);
  }
  if (memStr.endsWith("KB")) {
    return to!long(memStr[0 .. $ - 2]) / 1024;
  }
  return to!long(memStr);
}

/// Formats memory size as human-readable string
string formatMemorySize(long bytes) @safe {
  if (bytes >= 1024L * 1024 * 1024) {
    return format("%.2f GB", cast(double)bytes / (1024 * 1024 * 1024));
  }
  if (bytes >= 1024L * 1024) {
    return format("%.2f MB", cast(double)bytes / (1024 * 1024));
  }
  if (bytes >= 1024) {
    return format("%.2f KB", cast(double)bytes / 1024);
  }
  return format("%d B", bytes);
}

/// Validates VM name format
bool isValidVMName(string name) @safe {
  if (name.length == 0 || name.length > 255) return false;
  
  foreach (char c; name) {
    if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
          (c >= '0' && c <= '9') || c == '-' || c == '_' || c == '.')) {
      return false;
    }
  }
  
  return true;
}

/// Validates MAC address format
bool isValidMACAddress(string mac) @safe {
  if (mac.length != 17) return false;
  
  int colonCount = 0;
  foreach (char c; mac) {
    if (c == ':') {
      colonCount++;
    } else if (!((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F'))) {
      return false;
    }
  }
  
  return colonCount == 5;
}

private bool endsWith(string str, string suffix) @safe {
  if (str.length < suffix.length) return false;
  return str[$ - suffix.length .. $] == suffix;
}
