/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.lxc.helpers;

import std.json : Json;

@safe:

/// Creates a basic container configuration.
Json createContainerConfig(string image, string[] cmd = []) {
  Json[] cmdArray;
  foreach (c; cmd) {
    cmdArray ~= Json(c);
  }

  Json config = Json([
    "source": Json([
      "type": Json("image"),
      "alias": Json(image)
    ])
  ]);

  if (cmdArray.length > 0) {
    config["command"] = Json(cmdArray);
  }

  return config;
}

/// Creates a container from an existing image with specific config.
Json createContainerFromImage(
  string imageAlias,
  string[string] environment = null,
  string[string] labels = null
) {
  Json config = Json([
    "source": Json([
      "type": Json("image"),
      "alias": Json(imageAlias)
    ])
  ]);

  if (environment.length > 0) {
    Json[string] env;
    foreach (key, value; environment) {
      env[key] = Json(value);
    }
    config["environment"] = Json(env);
  }

  if (labels.length > 0) {
    Json[string] lbl;
    foreach (key, value; labels) {
      lbl[key] = Json(value);
    }
    config["config"] = Json(lbl);
  }

  return config;
}

/// Creates network configuration for a container.
Json createNetworkConfig(string networkName, string ipAddress = "") {
  Json config = Json([
    "name": Json("eth0"),
    "type": Json("nic"),
    "nictype": Json("bridged"),
    "parent": Json(networkName)
  ]);

  if (ipAddress.length > 0) {
    Json[string] ipv4Config;
    ipv4Config["address"] = Json(ipAddress);
    config["ipv4"] = Json(ipv4Config);
  }

  return config;
}

/// Creates storage device configuration.
Json createStorageDeviceConfig(string storagePath, string devicePath = "/") {
  Json config = Json([
    "type": Json("disk"),
    "source": Json(storagePath),
    "path": Json(devicePath)
  ]);
  return config;
}

/// Creates a bridge network configuration.
Json createBridgeNetworkConfig(
  string name,
  string ipv4Address = "10.0.0.1/24",
  string ipv4Nat = "true"
) {
  Json config = Json([
    "name": Json(name),
    "type": Json("bridge"),
    "config": Json([
      "ipv4.address": Json(ipv4Address),
      "ipv4.nat": Json(ipv4Nat),
      "ipv4.dhcp": Json("true")
    ])
  ]);
  return config;
}

/// Creates a storage pool configuration for directory-based storage.
Json createDirStoragePoolConfig(string name, string path) {
  Json config = Json([
    "name": Json(name),
    "driver": Json("dir"),
    "config": Json([
      "source": Json(path)
    ])
  ]);
  return config;
}

/// Creates a storage pool configuration for LVM-based storage.
Json createLVMStoragePoolConfig(string name, string volumeGroup) {
  Json config = Json([
    "name": Json(name),
    "driver": Json("lvm"),
    "config": Json([
      "source": Json(volumeGroup),
      "volume.lvm.vg_name": Json(volumeGroup)
    ])
  ]);
  return config;
}

/// Creates a storage pool configuration for ZFS-based storage.
Json createZFSStoragePoolConfig(string name, string poolName) {
  Json config = Json([
    "name": Json(name),
    "driver": Json("zfs"),
    "config": Json([
      "source": Json(poolName)
    ])
  ]);
  return config;
}

/// Creates a device configuration for passing through host devices.
Json createDeviceConfig(string type, string source, string devicePath = "") {
  Json config = Json([
    "type": Json(type),
    "source": Json(source)
  ]);

  if (devicePath.length > 0) {
    config["path"] = Json(devicePath);
  }

  return config;
}

/// Creates CPU limits configuration.
Json createCPULimitsConfig(int cpuAllowance = 100, int cpuPriority = 10) {
  Json config = Json([
    "limits.cpu": Json(cpuAllowance),
    "limits.cpu.priority": Json(cpuPriority)
  ]);
  return config;
}

/// Creates memory limits configuration.
Json createMemoryLimitsConfig(long maxMemoryBytes = 0, long swapBytes = 0) {
  Json config = Json(Json(null).object);

  if (maxMemoryBytes > 0) {
    config["limits.memory"] = Json(format("%dB", maxMemoryBytes));
  }

  if (swapBytes > 0) {
    config["limits.memory.swap"] = Json(format("%dB", swapBytes));
  }

  return config;
}

/// Creates security limits configuration.
Json createSecurityConfig(
  bool privileged = false,
  string[] allowedDevices = null
) {
  Json config = Json([
    "security.privileged": Json(privileged ? "true" : "false")
  ]);

  if (allowedDevices && allowedDevices.length > 0) {
    string allowedStr = "";
    foreach (i, device; allowedDevices) {
      if (i > 0) allowedStr ~= " ";
      allowedStr ~= device;
    }
    config["security.syscalls.blacklist"] = Json(allowedStr);
  }

  return config;
}

/// Converts string map to Json config object.
Json configMapToJSON(string[string] configMap) {
  Json[string] result;
  foreach (key, value; configMap) {
    result[key] = Json(value);
  }
  return Json(result);
}

/// Merges multiple configuration objects.
Json mergeConfigs(Json[] configs...) {
  Json result = Json(Json(null).object);

  foreach (config; configs) {
    if (config.type == Json.Type.object) {
      foreach (key, value; config.object) {
        result[key] = value;
      }
    }
  }

  return result;
}
