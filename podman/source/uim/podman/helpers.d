/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.helpers;

import std.json : JSONValue;

@safe:

/// Creates a container config for a simple image run.
JSONValue createContainerConfig(string image, string[] cmd = [], string[] env = []) {
  JSONValue[] cmdArray;
  foreach (c; cmd) {
    cmdArray ~= JSONValue(c);
  }

  JSONValue[] envArray;
  foreach (e; env) {
    envArray ~= JSONValue(e);
  }

  JSONValue config = JSONValue([
    "Image": JSONValue(image),
    "Cmd": JSONValue(cmdArray),
    "Env": JSONValue(envArray)
  ]);
  return config;
}

/// Creates port bindings for container.
JSONValue createPortBindings(string[string] portMap) {
  JSONValue[string] bindings;
  foreach (containerPort, hostPort; portMap) {
    bindings[containerPort] = JSONValue([
      JSONValue([
        "HostPort": JSONValue(hostPort)
      ])
    ]);
  }
  return JSONValue(bindings);
}

/// Creates volume mounts for container.
JSONValue createVolumeMounts(string[string] mounts) {
  JSONValue[] volumeList;
  foreach (containerPath, hostPath; mounts) {
    volumeList ~= JSONValue([
      "Source": JSONValue(hostPath),
      "Target": JSONValue(containerPath),
      "Type": JSONValue("bind")
    ]);
  }
  return JSONValue(volumeList);
}

/// Creates environment variables array from key-value pairs.
JSONValue createEnvironment(string[string] envMap) {
  JSONValue[] envArray;
  foreach (key, value; envMap) {
    envArray ~= JSONValue(key ~ "=" ~ value);
  }
  return JSONValue(envArray);
}

/// Creates a pod config for a simple pod creation.
JSONValue createPodConfig(string name, string[] portBindings = []) {
  JSONValue[] ports;
  foreach (port; portBindings) {
    ports ~= JSONValue(port);
  }

  JSONValue config = JSONValue([
    "Name": JSONValue(name),
    "Share": JSONValue(["pid", "ipc", "uts"])
  ]);
  
  if (ports.length > 0) {
    config["PortMappings"] = JSONValue(ports);
  }
  
  return config;
}

/// Creates network settings for container.
JSONValue createNetworkSettings(string networkName, string ipAddress = "", string gateway = "") {
  JSONValue settings = JSONValue([
    "EndpointsConfig": JSONValue([
      networkName: JSONValue([
        "IPAMConfig": JSONValue(JSONValue(null))
      ])
    ])
  ]);
  
  if (ipAddress.length > 0) {
    settings["EndpointsConfig"][networkName]["IPAMConfig"] = JSONValue([
      "IPv4Address": JSONValue(ipAddress)
    ]);
  }
  
  return settings;
}

/// Converts string array to JSONValue array.
JSONValue stringArrayToJSON(string[] array) {
  JSONValue[] result;
  foreach (item; array) {
    result ~= JSONValue(item);
  }
  return JSONValue(result);
}

/// Converts string map to JSONValue object.
JSONValue stringMapToJSON(string[string] map) {
  JSONValue[string] result;
  foreach (key, value; map) {
    result[key] = JSONValue(value);
  }
  return JSONValue(result);
}

/// Creates resource limits for container.
JSONValue createResourceLimits(long memoryBytes = 0, long cpuNanos = 0, long cpuShares = 1024) {
  JSONValue limits = JSONValue([
    "MemorySwap": JSONValue(-1),
    "CpuShares": JSONValue(cpuShares)
  ]);
  
  if (memoryBytes > 0) {
    limits["Memory"] = JSONValue(memoryBytes);
  }
  
  if (cpuNanos > 0) {
    limits["CpuNano"] = JSONValue(cpuNanos);
  }
  
  return limits;
}

/// Creates health check configuration.
JSONValue createHealthCheck(string[] testCmd, int interval = 30, int timeout = 10, int retries = 3, int startPeriod = 0) {
  JSONValue healthCheck = JSONValue([
    "Test": JSONValue(testCmd),
    "Interval": JSONValue(interval * 1_000_000_000L),  // Convert to nanoseconds
    "Timeout": JSONValue(timeout * 1_000_000_000L),
    "Retries": JSONValue(retries),
    "StartPeriod": JSONValue(startPeriod * 1_000_000_000L)
  ]);
  return healthCheck;
}
