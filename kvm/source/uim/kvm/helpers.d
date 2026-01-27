/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.kvm.helpers;

import std.json : JSONValue;
import std.format : format;

@safe:

/// Minimal domain definition (JSON placeholder for XML)
JSONValue createDomainDefinition(
  string name,
  int vcpus = 2,
  long memoryMiB = 2048,
  string osType = "hvm",
  string arch = "x86_64"
) {
  JSONValue defn = JSONValue([
    "name": JSONValue(name),
    "vcpus": JSONValue(vcpus),
    "memory": JSONValue(memoryMiB * 1024), // libvirt expects KiB
    "ostype": JSONValue(osType),
    "arch": JSONValue(arch)
  ]);
  return defn;
}

/// Snapshot definition helper
JSONValue createSnapshotDefinition(string name, string description = "") {
  JSONValue defn = JSONValue(["name": JSONValue(name)]);
  if (description.length > 0) defn["description"] = JSONValue(description);
  return defn;
}

/// Storage pool definition helper
JSONValue createStoragePoolDefinition(string name, string type = "dir", string path = "/var/lib/libvirt/images") {
  return JSONValue([
    "name": JSONValue(name),
    "type": JSONValue(type),
    "path": JSONValue(path)
  ]);
}

/// Network definition helper
JSONValue createNetworkDefinition(string name, string mode = "nat", string bridge = "virbr0") {
  return JSONValue([
    "name": JSONValue(name),
    "mode": JSONValue(mode),
    "bridge": JSONValue(bridge)
  ]);
}

/// Pretty print memory in MiB
string formatMemoryMiB(long mib) {
  if (mib >= 1024 * 1024) return format("%.2f TiB", cast(double)mib / (1024 * 1024));
  if (mib >= 1024) return format("%.2f GiB", cast(double)mib / 1024);
  return format("%d MiB", mib);
}
