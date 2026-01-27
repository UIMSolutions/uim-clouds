/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.virtualbox.helpers;

import std.json : JSONValue;
import std.format : format;

@safe:

/// Builds a minimal VM definition
JSONValue createVMDefinition(
  string name,
  int cpuCount = 2,
  long memoryMB = 2048,
  string osType = "Linux_64"
) {
  JSONValue config = JSONValue([
    "name": JSONValue(name),
    "cpus": JSONValue(cpuCount),
    "memory": JSONValue(memoryMB),
    "ostype": JSONValue(osType)
  ]);
  return config;
}

/// Creates a storage attachment (disk or ISO)
JSONValue createStorageAttachment(
  string controller,
  string port,
  string device,
  string medium,
  string type = "hdd"
) {
  return JSONValue([
    "controller": JSONValue(controller),
    "port": JSONValue(port),
    "device": JSONValue(device),
    "medium": JSONValue(medium),
    "type": JSONValue(type)
  ]);
}

/// Creates a NIC configuration
JSONValue createNIC(
  string slot,
  string mode = "nat",
  string attachment = "",
  string driver = "virtio",
  string macAddress = ""
) {
  JSONValue cfg = JSONValue([
    "slot": JSONValue(slot),
    "type": JSONValue(mode),
    "driver": JSONValue(driver)
  ]);
  if (attachment.length > 0) cfg["attachment"] = JSONValue(attachment);
  if (macAddress.length > 0) cfg["mac"] = JSONValue(macAddress);
  return cfg;
}

/// Creates a snapshot description
JSONValue createSnapshotDefinition(string name, string description = "") {
  JSONValue cfg = JSONValue(["name": JSONValue(name)]);
  if (description.length > 0) cfg["description"] = JSONValue(description);
  return cfg;
}

/// Human-readable memory formatting
string formatMemoryMB(long mb) @safe {
  if (mb >= 1024 * 1024) return format("%.2f TB", cast(double)mb / (1024 * 1024));
  if (mb >= 1024) return format("%.2f GB", cast(double)mb / 1024);
  return format("%d MB", mb);
}
