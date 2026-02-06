/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.helpers.helpers;

import uim.podman;

@safe:



/// Creates port bindings for container.
Json createPortBindings(string[string] portMap) {
  Json[string] bindings;
  foreach (containerPort, hostPort; portMap) {
    bindings[containerPort] = Json([
      Json([
        "HostPort": Json(hostPort)
      ])
    ]);
  }
  return Json(bindings);
}

/// Creates volume mounts for container.
Json createVolumeMounts(string[string] mounts) {
  Json[] volumeList;
  foreach (containerPath, hostPath; mounts) {
    volumeList ~= Json([
      "Source": Json(hostPath),
      "Target": Json(containerPath),
      "Type": Json("bind")
    ]);
  }
  return Json(volumeList);
}



/// Creates a pod config for a simple pod creation.
Json createPodConfig(string name, string[] portBindings = []) {
  Json[] ports;
  foreach (port; portBindings) {
    ports ~= Json(port);
  }

  Json config = Json([
    "Name": Json(name),
    "Share": Json(["pid", "ipc", "uts"])
  ]);
  
  if (ports.length > 0) {
    config["PortMappings"] = Json(ports);
  }
  
  return config;
}



/// Converts string array to Json array.
Json stringArrayToJSON(string[] array) {
  Json[] result;
  foreach (item; array) {
    result ~= Json(item);
  }
  return Json(result);
}

/// Converts string map to Json object.
Json stringMapToJSON(string[string] map) {
  Json[string] result;
  foreach (key, value; map) {
    result[key] = Json(value);
  }
  return Json(result);
}

/// Creates resource limits for container.
Json createResourceLimits(long memoryBytes = 0, long cpuNanos = 0, long cpuShares = 1024) {
  Json limits = Json([
    "MemorySwap": Json(-1),
    "CpuShares": Json(cpuShares)
  ]);
  
  if (memoryBytes > 0) {
    limits["Memory"] = Json(memoryBytes);
  }
  
  if (cpuNanos > 0) {
    limits["CpuNano"] = Json(cpuNanos);
  }
  
  return limits;
}

/// Creates health check configuration.
Json createHealthCheck(string[] testCmd, int interval = 30, int timeout = 10, int retries = 3, int startPeriod = 0) {
  Json healthCheck = Json([
    "Test": Json(testCmd),
    "Interval": Json(interval * 1_000_000_000L),  // Convert to nanoseconds
    "Timeout": Json(timeout * 1_000_000_000L),
    "Retries": Json(retries),
    "StartPeriod": Json(startPeriod * 1_000_000_000L)
  ]);
  return healthCheck;
}
