/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.virtualbox.resources;

import std.json : Json;
import std.conv : to;

@safe:

/// Represents a VirtualBox VM
struct VBoxVM {
  string id;
  string name;
  string state;           // running, poweredoff, paused, aborted, saved
  long memoryMB;
  int cpuCount;
  string osType;
  string currentSnapshot;
  string uuid;
  string acpiState;

  this(Json data) {
    if (auto id = "id" in data.object) this.id = id.toString;
    if (auto name = "name" in data.object) this.name = name.toString;
    if (auto state = "state" in data.object) this.state = state.toString;
    if (auto mem = "memory" in data.object) this.memoryMB = mem.integer;
    if (auto cpu = "cpus" in data.object) this.cpuCount = cast(int)cpu.integer;
    if (auto os = "ostype" in data.object) this.osType = os.toString;
    if (auto uuid = "uuid" in data.object) this.uuid = uuid.toString;
  }
}

/// Represents a snapshot
struct VBoxSnapshot {
  string id;
  string name;
  string description;
  long timeStamp;
  bool current;

  this(Json data) {
    if (auto id = "id" in data.object) this.id = id.toString;
    if (auto name = "name" in data.object) this.name = name.toString;
    if (auto desc = "description" in data.object) this.description = desc.toString;
    if (auto ts = "timestamp" in data.object) this.timeStamp = ts.integer;
    if (auto cur = "current" in data.object) this.current = cur.type == Json.Type.true_;
  }
}

/// Represents storage attachment
struct VBoxStorageAttachment {
  string port;
  string device;
  string type;        // hdd, dvd, floppy
  string medium;      // path to image
  string controller;

  this(Json data) {
    if (auto port = "port" in data.object) this.port = port.toString;
    if (auto dev = "device" in data.object) this.device = dev.toString;
    if (auto type = "type" in data.object) this.type = type.toString;
    if (auto medium = "medium" in data.object) this.medium = medium.toString;
    if (auto ctl = "controller" in data.object) this.controller = ctl.toString;
  }
}

/// Represents a network adapter
struct VBoxNIC {
  string slot;
  string type;        // nat, bridged, hostonly, intnet, generic, null
  string macAddress;
  string attachment;  // bridge name or host-only name
  bool cableConnected;
  string driver;      // virtio, e1000, etc.

  this(Json data) {
    if (auto slot = "slot" in data.object) this.slot = slot.toString;
    if (auto type = "type" in data.object) this.type = type.toString;
    if (auto mac = "mac" in data.object) this.macAddress = mac.toString;
    if (auto att = "attachment" in data.object) this.attachment = att.toString;
    if (auto cable = "cable" in data.object) this.cableConnected = cable.type == Json.Type.true_;
    if (auto drv = "driver" in data.object) this.driver = drv.toString;
  }
}

/// Represents host info
struct VBoxHostInfo {
  string hostName;
  int cpuCount;
  long memoryMB;
  string vboxVersion;
  string vrdeSupported;
}
