/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.virtualization.helpers;

import std.json : JSONValue;
import std.conv : to;
import std.format : format;

import uim.virtualization.resources;
import uim.virtualization.config;

@safe:

/// Creates a basic VM configuration
JSONValue createVMConfig(
  string name,
  int vcpuCount = 2,
  long memoryMB = 2048,
  string osType = "linux"
) {
  JSONValue config = JSONValue([
    "name": JSONValue(name),
    "memory": JSONValue(memoryMB),
    "vcpus": JSONValue(vcpuCount),
    "os": JSONValue(["type": JSONValue(osType)])
  ]);
  return config;
}

/// Creates a VM disk configuration
JSONValue createVMDiskConfig(
  string sourcePath,
  string targetDevice = "vda",
  string type = "disk",
  string format = "qcow2",
  bool readonly = false
) {
  JSONValue config = JSONValue([
    "type": JSONValue(type),
    "source": JSONValue(sourcePath),
    "target": JSONValue(targetDevice),
    "format": JSONValue(format),
    "readonly": JSONValue(readonly)
  ]);
  return config;
}

/// Creates a VM network interface configuration
JSONValue createVMNICConfig(
  string networkName,
  string model = "virtio",
  string macAddress = ""
) {
  JSONValue config = JSONValue([
    "type": JSONValue("network"),
    "network": JSONValue(networkName),
    "model": JSONValue(model)
  ]);
  
  if (macAddress.length > 0) {
    config["mac"] = JSONValue(macAddress);
  }
  
  return config;
}

/// Creates a bridged network interface configuration
JSONValue createBridgedNICConfig(
  string bridgeName,
  string model = "virtio",
  string macAddress = ""
) {
  JSONValue config = JSONValue([
    "type": JSONValue("bridge"),
    "source": JSONValue(bridgeName),
    "model": JSONValue(model)
  ]);
  
  if (macAddress.length > 0) {
    config["mac"] = JSONValue(macAddress);
  }
  
  return config;
}

/// Creates a NAT network configuration
JSONValue createNATNetworkConfig(
  string networkName,
  string ipv4Network = "192.168.122.0/24",
  bool enableDhcp = true
) {
  JSONValue config = JSONValue([
    "name": JSONValue(networkName),
    "forward": JSONValue(["mode": JSONValue("nat")]),
    "bridge": JSONValue(["name": JSONValue("virbr0")]),
    "ip": JSONValue([
      "address": JSONValue("192.168.122.1"),
      "netmask": JSONValue("255.255.255.0")
    ])
  ]);
  
  if (enableDhcp) {
    config["dhcp"] = JSONValue([
      "start": JSONValue("192.168.122.2"),
      "end": JSONValue("192.168.122.254")
    ]);
  }
  
  return config;
}

/// Creates a bridged network configuration
JSONValue createBridgedNetworkConfig(
  string networkName,
  string bridgeName = "br0",
  string bridgeType = "bridge"
) {
  JSONValue config = JSONValue([
    "name": JSONValue(networkName),
    "forward": JSONValue(["mode": JSONValue("bridge")]),
    "bridge": JSONValue([
      "name": JSONValue(bridgeName),
      "type": JSONValue(bridgeType)
    ])
  ]);
  
  return config;
}

/// Creates a storage pool configuration for directory-based storage
JSONValue createDirStoragePoolConfig(
  string poolName,
  string path
) {
  JSONValue config = JSONValue([
    "name": JSONValue(poolName),
    "type": JSONValue("dir"),
    "target": JSONValue(["path": JSONValue(path)])
  ]);
  return config;
}

/// Creates a storage pool configuration for logical volume management
JSONValue createLVMStoragePoolConfig(
  string poolName,
  string volumeGroup,
  string targetPath = "/dev"
) {
  JSONValue config = JSONValue([
    "name": JSONValue(poolName),
    "type": JSONValue("logical"),
    "source": JSONValue(["name": JSONValue(volumeGroup)]),
    "target": JSONValue(["path": JSONValue(targetPath ~ "/" ~ volumeGroup)])
  ]);
  return config;
}

/// Creates a storage volume configuration
JSONValue createStorageVolumeConfig(
  string volumeName,
  long sizeBytes,
  string format = "qcow2"
) {
  JSONValue config = JSONValue([
    "name": JSONValue(volumeName),
    "capacity": JSONValue(sizeBytes),
    "format": JSONValue(["type": JSONValue(format)])
  ]);
  return config;
}

/// Creates a storage volume from a backing store (CoW)
JSONValue createCowVolumeConfig(
  string volumeName,
  string backingStorePath,
  long sizeBytes = 0
) {
  JSONValue config = JSONValue([
    "name": JSONValue(volumeName),
    "backingStore": JSONValue(["path": JSONValue(backingStorePath), "format": JSONValue("qcow2")])
  ]);
  
  if (sizeBytes > 0) {
    config["capacity"] = JSONValue(sizeBytes);
  }
  
  return config;
}

/// Creates CPU configuration for a VM
JSONValue createVMCPUConfig(
  int vCpuCount,
  string model = "host-passthrough",
  int sockets = 1,
  int cores = 2,
  int threads = 1
) {
  JSONValue config = JSONValue([
    "vcpus": JSONValue(vCpuCount),
    "cpu": JSONValue([
      "model": JSONValue(model),
      "topology": JSONValue([
        "sockets": JSONValue(sockets),
        "cores": JSONValue(cores),
        "threads": JSONValue(threads)
      ])
    ])
  ]);
  return config;
}

/// Creates memory configuration for a VM
JSONValue createVMMemoryConfig(
  long memoryMB,
  long maxMemoryMB = 0
) {
  JSONValue config = JSONValue([
    "memory": JSONValue(memoryMB),
    "unit": JSONValue("MiB")
  ]);
  
  if (maxMemoryMB > 0) {
    config["maxMemory"] = JSONValue(maxMemoryMB);
  }
  
  return config;
}

/// Creates console/serial port configuration
JSONValue createConsoleConfig(
  string type = "pty",
  int targetPort = 0
) {
  JSONValue config = JSONValue([
    "type": JSONValue(type),
    "target": JSONValue(["port": JSONValue(targetPort)])
  ]);
  return config;
}

/// Creates UEFI/BIOS boot configuration
JSONValue createBootConfig(
  string firmware = "bios",
  string[] bootDevices = null
) {
  JSONValue config = JSONValue([
    "firmware": JSONValue(firmware)
  ]);
  
  if (bootDevices && bootDevices.length > 0) {
    JSONValue[] bootOrder;
    foreach (device; bootDevices) {
      bootOrder ~= JSONValue(["dev": JSONValue(device)]);
    }
    config["bootOrder"] = JSONValue(bootOrder);
  }
  
  return config;
}

/// Creates a complete KVM/QEMU VM template
JSONValue createKVMVMTemplate(
  string name,
  int vcpuCount = 4,
  long memoryMB = 4096,
  string diskPath = "",
  string networkName = "default",
  string osType = "linux"
) {
  JSONValue config = createVMConfig(name, vcpuCount, memoryMB, osType);
  
  // Add disk if provided
  if (diskPath.length > 0) {
    JSONValue[] disks;
    disks ~= createVMDiskConfig(diskPath, "vda", "disk", "qcow2");
    config["devices"] = JSONValue(["disk": JSONValue(disks)]);
  }
  
  // Add network interface
  JSONValue[] nics;
  nics ~= createVMNICConfig(networkName);
  config["devices"]["interface"] = JSONValue(nics);
  
  // Add console
  config["devices"]["console"] = JSONValue([createConsoleConfig()]);
  
  // Add boot configuration
  config["boot"] = JSONValue(createBootConfig("bios", ["disk", "cdrom"]));
  
  return config;
}

/// Creates a container-like lightweight VM
JSONValue createLightweightVMTemplate(
  string name,
  long memoryMB = 512,
  int vcpuCount = 1
) {
  return createVMConfig(name, vcpuCount, memoryMB, "linux");
}

/// Merges two VM configurations
JSONValue mergeVMConfigs(JSONValue baseConfig, JSONValue additionalConfig) {
  JSONValue result = baseConfig;
  
  if (additionalConfig.type == JSONValue.Type.object) {
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
