/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.namespaces.helpers;

import std.format : format;
import std.conv : to;

import uim.namespaces.types;

@safe:

/// Creates a user namespace configuration with standard UID/GID mappings
UserNamespaceConfig createStandardUserNamespace(uint insideUid = 0, uint insideGid = 0) {
  UserNamespaceConfig config;
  
  IDMapping uidMap;
  uidMap.insideId = insideUid;
  uidMap.outsideId = 0;
  uidMap.rangeSize = 65536;
  config.uidMappings ~= uidMap;
  
  IDMapping gidMap;
  gidMap.insideId = insideGid;
  gidMap.outsideId = 0;
  gidMap.rangeSize = 65536;
  config.gidMappings ~= gidMap;
  
  config.denySetgroups = false;
  
  return config;
}

/// Creates a user namespace configuration with nested UID/GID ranges
UserNamespaceConfig createNestedUserNamespace(
  uint outerMinUid = 100000,
  uint outerMinGid = 100000,
  uint rangeSize = 65536
) {
  UserNamespaceConfig config;
  
  IDMapping uidMap;
  uidMap.insideId = 0;
  uidMap.outsideId = outerMinUid;
  uidMap.rangeSize = rangeSize;
  config.uidMappings ~= uidMap;
  
  IDMapping gidMap;
  gidMap.insideId = 0;
  gidMap.outsideId = outerMinGid;
  gidMap.rangeSize = rangeSize;
  config.gidMappings ~= gidMap;
  
  config.denySetgroups = true;
  
  return config;
}

/// Formats UID mapping for writing to uid_map
string formatUIDMapping(IDMapping mapping) {
  return format("%d %d %d", mapping.insideId, mapping.outsideId, mapping.rangeSize);
}

/// Formats GID mapping for writing to gid_map
string formatGIDMapping(IDMapping mapping) {
  return format("%d %d %d", mapping.insideId, mapping.outsideId, mapping.rangeSize);
}

/// Creates a common namespace isolation set for containers
NamespaceType[] getContainerNamespaces() {
  return [
    NamespaceType.PID,
    NamespaceType.Network,
    NamespaceType.IPC,
    NamespaceType.Mount,
    NamespaceType.UTS,
    NamespaceType.User,
    NamespaceType.Cgroup
  ];
}

/// Creates a minimal isolation set (process isolation only)
NamespaceType[] getMinimalNamespaces() {
  return [
    NamespaceType.PID,
    NamespaceType.Mount,
    NamespaceType.UTS
  ];
}

/// Creates a network-focused isolation set
NamespaceType[] getNetworkIsolationNamespaces() {
  return [
    NamespaceType.PID,
    NamespaceType.Network,
    NamespaceType.Mount,
    NamespaceType.UTS
  ];
}

/// Checks if two PIDs are in the same namespace
bool sameNamespace(int pid1, int pid2, NamespaceType type) @trusted {
  // This would compare inode numbers from /proc/[pid]/ns/[type]
  // Placeholder implementation
  return false;
}

/// Gets a human-readable description of namespace type
string describeNamespaceType(NamespaceType type) {
  switch (type) {
    case NamespaceType.PID:
      return "Process ID Namespace - Isolates process IDs";
    case NamespaceType.Network:
      return "Network Namespace - Isolates network resources (interfaces, routing, firewall)";
    case NamespaceType.IPC:
      return "IPC Namespace - Isolates System V IPC objects (message queues, shared memory, semaphores)";
    case NamespaceType.Mount:
      return "Mount Namespace - Isolates filesystem mount points";
    case NamespaceType.UTS:
      return "UTS Namespace - Isolates hostname and domain name";
    case NamespaceType.User:
      return "User Namespace - Isolates user and group IDs";
    case NamespaceType.Cgroup:
      return "Cgroup Namespace - Isolates cgroup hierarchy";
    default:
      return "Unknown Namespace Type";
  }
}

/// Formats namespace information for display
string formatNamespaceInfo(NamespaceInfo ns) {
  return format("Type: %s, Inode: %d, Path: %s", ns.type, ns.inode, ns.path);
}

/// Formats process info with all namespaces
string formatProcessInfo(ProcessInfo proc) {
  string result = format("PID: %d, Command: %s, State: %s\n", proc.pid, proc.command, proc.state);
  result ~= "  Namespaces:\n";
  foreach (ns; proc.namespaces) {
    result ~= format("    - %s\n", formatNamespaceInfo(ns));
  }
  return result;
}

/// Gets capabilities required for namespace operations
string[] getRequiredCapabilities(NamespaceType type) {
  string[] caps = ["CAP_SYS_ADMIN"];
  
  if (type == NamespaceType.User) {
    caps ~= "CAP_SETUID";
    caps ~= "CAP_SETGID";
  }
  
  if (type == NamespaceType.Network) {
    caps ~= "CAP_NET_ADMIN";
  }
  
  if (type == NamespaceType.Mount) {
    caps ~= "CAP_SYS_CHROOT";
  }
  
  return caps;
}

/// Validates if a UID mapping is valid
bool isValidUIDMapping(IDMapping mapping) {
  if (mapping.insideId >= 4294967295U) return false;  // Max UID
  if (mapping.outsideId >= 4294967295U) return false;
  if (mapping.rangeSize == 0) return false;
  return true;
}

/// Creates an IDMapping from individual components
IDMapping createIDMapping(uint insideId, uint outsideId, uint rangeSize) {
  IDMapping mapping;
  mapping.insideId = insideId;
  mapping.outsideId = outsideId;
  mapping.rangeSize = rangeSize;
  return mapping;
}

/// Merges multiple UID mappings
IDMapping[] mergeUIDMappings(IDMapping[][] mappings...) {
  IDMapping[] result;
  foreach (mapGroup; mappings) {
    result ~= mapGroup;
  }
  return result;
}

/// Gets default cgroup configuration for a namespace
CgroupInfo getDefaultCgroupConfig() {
  CgroupInfo info;
  info.path = "/";
  info.controllers = ["cpu", "memory", "cpuset", "pids"];
  info.memoryLimit = "";
  info.cpuLimit = "";
  info.pidLimit = "";
  return info;
}

/// Creates mount options for namespace isolation
string createMountOptions(string[] options = []) {
  string[] defaultOpts = ["nosuid", "nodev", "noexec"];
  foreach (opt; options) {
    defaultOpts ~= opt;
  }
  
  string result = "";
  foreach (i, opt; defaultOpts) {
    if (i > 0) result ~= ",";
    result ~= opt;
  }
  return result;
}
