/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.kvm.resources;

import std.json : Json;

@safe:

/// Represents a KVM/libvirt domain
struct KVMDomain {
  string id;
  string name;
  string state;       // running, shutoff, paused, crashed
  long memoryKiB;
  int vcpus;
  string osType;
  string arch;
  string machine;
  string uuid;
  bool autostart;

  this(Json data) {
    if (auto idVal = "id" in data.object) this.id = idVal.toString;
    if (auto nameVal = "name" in data.object) this.name = nameVal.toString;
    if (auto stateVal = "state" in data.object) this.state = stateVal.toString;
    if (auto mem = "memory" in data.object) this.memoryKiB = mem.integer;
    if (auto cpu = "vcpus" in data.object) this.vcpus = cast(int)cpu.integer;
    if (auto os = "ostype" in data.object) this.osType = os.toString;
    if (auto archVal = "arch" in data.object) this.arch = archVal.toString;
    if (auto mach = "machine" in data.object) this.machine = mach.toString;
    if (auto uuidVal = "uuid" in data.object) this.uuid = uuidVal.toString;
    if (auto autoVal = "autostart" in data.object) this.autostart = autoVal.type == Json.Type.true_;
  }
}

/// Represents a domain snapshot
struct KVMSnapshot {
  string name;
  string parent;
  string description;
  string state;
  long creationTime;
  bool current;

  this(Json data) {
    if (auto nameVal = "name" in data.object) this.name = nameVal.toString;
    if (auto parentVal = "parent" in data.object) this.parent = parentVal.toString;
    if (auto desc = "description" in data.object) this.description = desc.toString;
    if (auto stateVal = "state" in data.object) this.state = stateVal.toString;
    if (auto ts = "creation" in data.object) this.creationTime = ts.integer;
    if (auto cur = "current" in data.object) this.current = cur.type == Json.Type.true_;
  }
}

/// Represents a storage pool
struct KVMStoragePool {
  string name;
  string state;
  string type;
  string path;
  bool autostart;

  this(Json data) {
    if (auto nameVal = "name" in data.object) this.name = nameVal.toString;
    if (auto stateVal = "state" in data.object) this.state = stateVal.toString;
    if (auto typeVal = "type" in data.object) this.type = typeVal.toString;
    if (auto pathVal = "path" in data.object) this.path = pathVal.toString;
    if (auto autoVal = "autostart" in data.object) this.autostart = autoVal.type == Json.Type.true_;
  }
}

/// Represents a virtual network
struct KVMNetwork {
  string name;
  string mode;       // nat, routed, isolated, bridged
  string bridge;
  string uuid;
  bool autostart;
  string status;

  this(Json data) {
    if (auto nameVal = "name" in data.object) this.name = nameVal.toString;
    if (auto modeVal = "mode" in data.object) this.mode = modeVal.toString;
    if (auto bridgeVal = "bridge" in data.object) this.bridge = bridgeVal.toString;
    if (auto uuidVal = "uuid" in data.object) this.uuid = uuidVal.toString;
    if (auto autoVal = "autostart" in data.object) this.autostart = autoVal.type == Json.Type.true_;
    if (auto statusVal = "status" in data.object) this.status = statusVal.toString;
  }
}

/// Represents host/node info
struct KVMHostInfo {
  string hostname;
  int cpuSockets;
  int cpuCores;
  int cpuThreads;
  long memoryKiB;
  string libvirtVersion;
  string hypervisorVersion;
}
