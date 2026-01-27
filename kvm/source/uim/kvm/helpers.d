/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.kvm.helpers;

import std.json : Json;
import std.format : format;

@safe:

/// Minimal domain definition (JSON placeholder for XML)
Json createDomainDefinition(
  string name,
  int vcpus = 2,
  long memoryMiB = 2048,
  string osType = "hvm",
  string arch = "x86_64"
) {
  Json defn = Json([
    "name": Json(name),
    "vcpus": Json(vcpus),
    "memory": Json(memoryMiB * 1024), // libvirt expects KiB
    "ostype": Json(osType),
    "arch": Json(arch)
  ]);
  return defn;
}

/// Snapshot definition helper
Json createSnapshotDefinition(string name, string description = "") {
  Json defn = Json(["name": Json(name)]);
  if (description.length > 0) defn["description"] = Json(description);
  return defn;
}

/// Storage pool definition helper
Json createStoragePoolDefinition(string name, string type = "dir", string path = "/var/lib/libvirt/images") {
  return Json([
    "name": Json(name),
    "type": Json(type),
    "path": Json(path)
  ]);
}

/// Network definition helper
Json createNetworkDefinition(string name, string mode = "nat", string bridge = "virbr0") {
  return Json([
    "name": Json(name),
    "mode": Json(mode),
    "bridge": Json(bridge)
  ]);
}

/// Pretty print memory in MiB
string formatMemoryMiB(long mib) {
  if (mib >= 1024 * 1024) return format("%.2f TiB", cast(double)mib / (1024 * 1024));
  if (mib >= 1024) return format("%.2f GiB", cast(double)mib / 1024);
  return format("%d MiB", mib);
}
