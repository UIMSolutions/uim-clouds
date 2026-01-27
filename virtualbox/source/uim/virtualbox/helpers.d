/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.virtualbox.helpers;

import std.json : Json;
import std.format : format;

@safe:

/// Builds a minimal VM definition
Json createVMDefinition(
  string name,
  int cpuCount = 2,
  long memoryMB = 2048,
  string osType = "Linux_64"
) {
  Json config = Json([
    "name": Json(name),
    "cpus": Json(cpuCount),
    "memory": Json(memoryMB),
    "ostype": Json(osType)
  ]);
  return config;
}

/// Creates a storage attachment (disk or ISO)
Json createStorageAttachment(
  string controller,
  string port,
  string device,
  string medium,
  string type = "hdd"
) {
  return Json([
    "controller": Json(controller),
    "port": Json(port),
    "device": Json(device),
    "medium": Json(medium),
    "type": Json(type)
  ]);
}

/// Creates a NIC configuration
Json createNIC(
  string slot,
  string mode = "nat",
  string attachment = "",
  string driver = "virtio",
  string macAddress = ""
) {
  Json cfg = Json([
    "slot": Json(slot),
    "type": Json(mode),
    "driver": Json(driver)
  ]);
  if (attachment.length > 0) cfg["attachment"] = Json(attachment);
  if (macAddress.length > 0) cfg["mac"] = Json(macAddress);
  return cfg;
}

/// Creates a snapshot description
Json createSnapshotDefinition(string name, string description = "") {
  Json cfg = Json(["name": Json(name)]);
  if (description.length > 0) cfg["description"] = Json(description);
  return cfg;
}

/// Human-readable memory formatting
string formatMemoryMB(long mb) @safe {
  if (mb >= 1024 * 1024) return format("%.2f TB", cast(double)mb / (1024 * 1024));
  if (mb >= 1024) return format("%.2f GB", cast(double)mb / 1024);
  return format("%d MB", mb);
}
