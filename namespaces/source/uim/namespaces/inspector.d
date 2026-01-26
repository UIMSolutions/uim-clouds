/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.namespaces.inspector;

import std.file : readText, exists, isFile;
import std.string : split, strip, startsWith;
import std.conv : to;
import std.format : format;
import std.array : split;
import std.algorithm : splitter;

import uim.namespaces.types;
import uim.namespaces.syscalls;

@safe:

/// Gets namespace information for a process
NamespaceInfo[] getProcessNamespaces(int pid) @trusted {
  NamespaceInfo[] namespaces;
  
  auto nsTypes = [
    NamespaceType.PID,
    NamespaceType.Network,
    NamespaceType.IPC,
    NamespaceType.Mount,
    NamespaceType.UTS,
    NamespaceType.User,
    NamespaceType.Cgroup
  ];
  
  foreach (type; nsTypes) {
    string path = format("/proc/%d/ns/%s", pid, namespaceTypeToString(type));
    if (exists(path) && isFile(path)) {
      auto info = getNamespaceInfo(path);
      if (info.inode > 0) {
        namespaces ~= info;
      }
    }
  }
  
  return namespaces;
}

/// Gets detailed namespace information from a namespace path
NamespaceInfo getNamespaceInfo(string namespacePath) @trusted {
  NamespaceInfo info;
  info.path = namespacePath;
  
  // Extract namespace type from path
  if (namespacePath.endsWith("/pid")) {
    info.type = "pid";
  } else if (namespacePath.endsWith("/net")) {
    info.type = "net";
  } else if (namespacePath.endsWith("/ipc")) {
    info.type = "ipc";
  } else if (namespacePath.endsWith("/mnt")) {
    info.type = "mnt";
  } else if (namespacePath.endsWith("/uts")) {
    info.type = "uts";
  } else if (namespacePath.endsWith("/user")) {
    info.type = "user";
  } else if (namespacePath.endsWith("/cgroup")) {
    info.type = "cgroup";
  }
  
  // Read namespace inode from stat information
  try {
    string statPath = namespacePath.replace("/ns/", "/ns/.stat/");
    // This is a simplified approach; in real implementation,
    // you would parse /proc/[pid]/status or use stat syscalls
    info.inode = hashPath(namespacePath);
  } catch (Exception e) {
    info.inode = 0;
  }
  
  return info;
}

/// Gets all process namespaces grouped by type
NamespaceHierarchy[] getNamespaceHierarchy() @trusted {
  NamespaceHierarchy[] hierarchies;
  
  auto nsTypes = [
    NamespaceType.PID,
    NamespaceType.Network,
    NamespaceType.IPC,
    NamespaceType.Mount,
    NamespaceType.UTS,
    NamespaceType.User,
    NamespaceType.Cgroup
  ];
  
  foreach (type; nsTypes) {
    auto processes = findProcessesInNamespace(type);
    if (processes.length > 0) {
      NamespaceHierarchy h;
      h.type = type;
      h.inode = hashNamespaceType(type);
      h.pidList = processes;
      h.childCount = 0;
      hierarchies ~= h;
    }
  }
  
  return hierarchies;
}

/// Finds all processes sharing a specific namespace
int[] findProcessesInNamespace(NamespaceType type) @trusted {
  int[] processes;
  string nsTypeStr = namespaceTypeToString(type);
  
  // This would scan /proc to find all processes with the same namespace
  // For now, this is a placeholder that shows the structure
  
  return processes;
}

/// Gets mount information from /proc/[pid]/mountinfo
MountInfo[] getMountInfo(int pid = -1) @trusted {
  MountInfo[] mounts;
  
  if (pid == -1) {
    pid = getPID();
  }
  
  string mountInfoPath = format("/proc/%d/mountinfo", pid);
  if (!exists(mountInfoPath)) {
    return mounts;
  }
  
  try {
    string content = readText(mountInfoPath);
    auto lines = content.split("\n");
    
    foreach (line; lines) {
      if (line.length == 0 || line.startsWith("#")) {
        continue;
      }
      
      auto parts = line.split(" ");
      if (parts.length >= 5) {
        MountInfo info;
        info.mountId = to!int(parts[0]);
        info.parentId = to!int(parts[1]);
        info.root = parts[4];
        info.mountPoint = parts[4 < parts.length - 1 ? 4 : 4];
        info.mountOptions = parts[5 < parts.length ? 5 : ""];
        mounts ~= info;
      }
    }
  } catch (Exception e) {
    // Return empty array on error
  }
  
  return mounts;
}

/// Gets network namespace information
NetworkNamespaceInfo getNetworkNamespaceInfo(int pid = -1) @trusted {
  NetworkNamespaceInfo info;
  
  if (pid == -1) {
    pid = getPID();
  }
  
  info.pid = pid;
  info.hasIpv4 = true;
  info.hasIpv6 = true;
  
  // This would read from /proc/[pid]/net/ to get network configuration
  
  return info;
}

/// Gets user namespace UID/GID mappings
IDMapping[] getUIDMappings(int pid = -1) @trusted {
  IDMapping[] mappings;
  
  if (pid == -1) {
    pid = getPID();
  }
  
  string mapPath = format("/proc/%d/uid_map", pid);
  if (!exists(mapPath)) {
    return mappings;
  }
  
  try {
    string content = readText(mapPath);
    auto lines = content.split("\n");
    
    foreach (line; lines) {
      if (line.length == 0) {
        continue;
      }
      
      auto parts = line.split(" ");
      if (parts.length >= 3) {
        IDMapping mapping;
        mapping.insideId = to!uint(parts[0]);
        mapping.outsideId = to!uint(parts[1]);
        mapping.rangeSize = to!uint(parts[2]);
        mappings ~= mapping;
      }
    }
  } catch (Exception e) {
    // Return empty array on error
  }
  
  return mappings;
}

/// Gets cgroup information for a process
CgroupInfo getCgroupInfo(int pid = -1) @trusted {
  CgroupInfo info;
  
  if (pid == -1) {
    pid = getPID();
  }
  
  string cgroupPath = format("/proc/%d/cgroup", pid);
  if (!exists(cgroupPath)) {
    return info;
  }
  
  try {
    string content = readText(cgroupPath);
    auto lines = content.split("\n");
    
    foreach (line; lines) {
      if (line.length == 0 || line.startsWith("#")) {
        continue;
      }
      
      auto parts = line.split(":");
      if (parts.length >= 3) {
        string controllers = parts[1];
        string path = parts[2];
        info.path = path;
        info.controllers ~= controllers;
      }
    }
  } catch (Exception e) {
    // Return empty cgroup info on error
  }
  
  return info;
}

// Private helper functions

private bool endsWith(string str, string suffix) @safe {
  if (str.length < suffix.length) return false;
  return str[$ - suffix.length .. $] == suffix;
}

private string replace(string str, string old, string replacement) @safe {
  size_t pos = 0;
  string result = str;
  while ((pos = result.indexOf(old, pos)) != size_t.max) {
    result = result[0 .. pos] ~ replacement ~ result[pos + old.length .. $];
    pos += replacement.length;
  }
  return result;
}

private size_t indexOf(string str, string needle, size_t start = 0) @safe {
  for (size_t i = start; i + needle.length <= str.length; ++i) {
    if (str[i .. i + needle.length] == needle) {
      return i;
    }
  }
  return size_t.max;
}

private ulong hashPath(string path) @safe {
  ulong hash = 0;
  foreach (char c; path) {
    hash = hash * 31 + c;
  }
  return hash;
}

private ulong hashNamespaceType(NamespaceType type) @safe {
  return cast(ulong)type;
}
