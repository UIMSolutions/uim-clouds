/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.kvm.resources;

import std.json : JSONValue;

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

  this(JSONValue data) {
    if (auto idVal = "id" in data.object) this.id = idVal.str;
    if (auto nameVal = "name" in data.object) this.name = nameVal.str;
    if (auto stateVal = "state" in data.object) this.state = stateVal.str;
    if (auto mem = "memory" in data.object) this.memoryKiB = mem.integer;
    if (auto cpu = "vcpus" in data.object) this.vcpus = cast(int)cpu.integer;
    if (auto os = "ostype" in data.object) this.osType = os.str;
    if (auto archVal = "arch" in data.object) this.arch = archVal.str;
    if (auto mach = "machine" in data.object) this.machine = mach.str;
    if (auto uuidVal = "uuid" in data.object) this.uuid = uuidVal.str;
    if (auto autoVal = "autostart" in data.object) this.autostart = autoVal.type == JSONValue.Type.true_;
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

  this(JSONValue data) {
    if (auto nameVal = "name" in data.object) this.name = nameVal.str;
    if (auto parentVal = "parent" in data.object) this.parent = parentVal.str;
    if (auto desc = "description" in data.object) this.description = desc.str;
    if (auto stateVal = "state" in data.object) this.state = stateVal.str;
    if (auto ts = "creation" in data.object) this.creationTime = ts.integer;
    if (auto cur = "current" in data.object) this.current = cur.type == JSONValue.Type.true_;
  }
}

/// Represents a storage pool
struct KVMStoragePool {
  string name;
  string state;
  string type;
  string path;
  bool autostart;

  this(JSONValue data) {
    if (auto nameVal = "name" in data.object) this.name = nameVal.str;
    if (auto stateVal = "state" in data.object) this.state = stateVal.str;
    if (auto typeVal = "type" in data.object) this.type = typeVal.str;
    if (auto pathVal = "path" in data.object) this.path = pathVal.str;
    if (auto autoVal = "autostart" in data.object) this.autostart = autoVal.type == JSONValue.Type.true_;
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

  this(JSONValue data) {
    if (auto nameVal = "name" in data.object) this.name = nameVal.str;
    if (auto modeVal = "mode" in data.object) this.mode = modeVal.str;
    if (auto bridgeVal = "bridge" in data.object) this.bridge = bridgeVal.str;
    if (auto uuidVal = "uuid" in data.object) this.uuid = uuidVal.str;
    if (auto autoVal = "autostart" in data.object) this.autostart = autoVal.type == JSONValue.Type.true_;
    if (auto statusVal = "status" in data.object) this.status = statusVal.str;
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
