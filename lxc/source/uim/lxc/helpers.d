/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.lxc.helpers;

import std.json : JSONValue;

@safe:

/// Creates a basic container configuration.
JSONValue createContainerConfig(string image, string[] cmd = []) {
  JSONValue[] cmdArray;
  foreach (c; cmd) {
    cmdArray ~= JSONValue(c);
  }

  JSONValue config = JSONValue([
    "source": JSONValue([
      "type": JSONValue("image"),
      "alias": JSONValue(image)
    ])
  ]);

  if (cmdArray.length > 0) {
    config["command"] = JSONValue(cmdArray);
  }

  return config;
}

/// Creates a container from an existing image with specific config.
JSONValue createContainerFromImage(
  string imageAlias,
  string[string] environment = null,
  string[string] labels = null
) {
  JSONValue config = JSONValue([
    "source": JSONValue([
      "type": JSONValue("image"),
      "alias": JSONValue(imageAlias)
    ])
  ]);

  if (environment.length > 0) {
    JSONValue[string] env;
    foreach (key, value; environment) {
      env[key] = JSONValue(value);
    }
    config["environment"] = JSONValue(env);
  }

  if (labels.length > 0) {
    JSONValue[string] lbl;
    foreach (key, value; labels) {
      lbl[key] = JSONValue(value);
    }
    config["config"] = JSONValue(lbl);
  }

  return config;
}

/// Creates network configuration for a container.
JSONValue createNetworkConfig(string networkName, string ipAddress = "") {
  JSONValue config = JSONValue([
    "name": JSONValue("eth0"),
    "type": JSONValue("nic"),
    "nictype": JSONValue("bridged"),
    "parent": JSONValue(networkName)
  ]);

  if (ipAddress.length > 0) {
    JSONValue[string] ipv4Config;
    ipv4Config["address"] = JSONValue(ipAddress);
    config["ipv4"] = JSONValue(ipv4Config);
  }

  return config;
}

/// Creates storage device configuration.
JSONValue createStorageDeviceConfig(string storagePath, string devicePath = "/") {
  JSONValue config = JSONValue([
    "type": JSONValue("disk"),
    "source": JSONValue(storagePath),
    "path": JSONValue(devicePath)
  ]);
  return config;
}

/// Creates a bridge network configuration.
JSONValue createBridgeNetworkConfig(
  string name,
  string ipv4Address = "10.0.0.1/24",
  string ipv4Nat = "true"
) {
  JSONValue config = JSONValue([
    "name": JSONValue(name),
    "type": JSONValue("bridge"),
    "config": JSONValue([
      "ipv4.address": JSONValue(ipv4Address),
      "ipv4.nat": JSONValue(ipv4Nat),
      "ipv4.dhcp": JSONValue("true")
    ])
  ]);
  return config;
}

/// Creates a storage pool configuration for directory-based storage.
JSONValue createDirStoragePoolConfig(string name, string path) {
  JSONValue config = JSONValue([
    "name": JSONValue(name),
    "driver": JSONValue("dir"),
    "config": JSONValue([
      "source": JSONValue(path)
    ])
  ]);
  return config;
}

/// Creates a storage pool configuration for LVM-based storage.
JSONValue createLVMStoragePoolConfig(string name, string volumeGroup) {
  JSONValue config = JSONValue([
    "name": JSONValue(name),
    "driver": JSONValue("lvm"),
    "config": JSONValue([
      "source": JSONValue(volumeGroup),
      "volume.lvm.vg_name": JSONValue(volumeGroup)
    ])
  ]);
  return config;
}

/// Creates a storage pool configuration for ZFS-based storage.
JSONValue createZFSStoragePoolConfig(string name, string poolName) {
  JSONValue config = JSONValue([
    "name": JSONValue(name),
    "driver": JSONValue("zfs"),
    "config": JSONValue([
      "source": JSONValue(poolName)
    ])
  ]);
  return config;
}

/// Creates a device configuration for passing through host devices.
JSONValue createDeviceConfig(string type, string source, string devicePath = "") {
  JSONValue config = JSONValue([
    "type": JSONValue(type),
    "source": JSONValue(source)
  ]);

  if (devicePath.length > 0) {
    config["path"] = JSONValue(devicePath);
  }

  return config;
}

/// Creates CPU limits configuration.
JSONValue createCPULimitsConfig(int cpuAllowance = 100, int cpuPriority = 10) {
  JSONValue config = JSONValue([
    "limits.cpu": JSONValue(cpuAllowance),
    "limits.cpu.priority": JSONValue(cpuPriority)
  ]);
  return config;
}

/// Creates memory limits configuration.
JSONValue createMemoryLimitsConfig(long maxMemoryBytes = 0, long swapBytes = 0) {
  JSONValue config = JSONValue(JSONValue(null).object);

  if (maxMemoryBytes > 0) {
    config["limits.memory"] = JSONValue(format("%dB", maxMemoryBytes));
  }

  if (swapBytes > 0) {
    config["limits.memory.swap"] = JSONValue(format("%dB", swapBytes));
  }

  return config;
}

/// Creates security limits configuration.
JSONValue createSecurityConfig(
  bool privileged = false,
  string[] allowedDevices = null
) {
  JSONValue config = JSONValue([
    "security.privileged": JSONValue(privileged ? "true" : "false")
  ]);

  if (allowedDevices && allowedDevices.length > 0) {
    string allowedStr = "";
    foreach (i, device; allowedDevices) {
      if (i > 0) allowedStr ~= " ";
      allowedStr ~= device;
    }
    config["security.syscalls.blacklist"] = JSONValue(allowedStr);
  }

  return config;
}

/// Converts string map to JSONValue config object.
JSONValue configMapToJSON(string[string] configMap) {
  JSONValue[string] result;
  foreach (key, value; configMap) {
    result[key] = JSONValue(value);
  }
  return JSONValue(result);
}

/// Merges multiple configuration objects.
JSONValue mergeConfigs(JSONValue[] configs...) {
  JSONValue result = JSONValue(JSONValue(null).object);

  foreach (config; configs) {
    if (config.type == JSONValue.Type.object) {
      foreach (key, value; config.object) {
        result[key] = value;
      }
    }
  }

  return result;
}
