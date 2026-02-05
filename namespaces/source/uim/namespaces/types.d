/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.namespaces.types;

import std.conv : to;

@safe:


/// String representation of namespace type
string namespaceTypeToString(NamespaceType type) @safe {
  switch (type) {
    case NamespaceType.PID:
      return "pid";
    case NamespaceType.Network:
      return "net";
    case NamespaceType.IPC:
      return "ipc";
    case NamespaceType.Mount:
      return "mnt";
    case NamespaceType.UTS:
      return "uts";
    case NamespaceType.User:
      return "user";
    case NamespaceType.Cgroup:
      return "cgroup";
    default:
      return "unknown";
  }
}

/// Parse namespace type from string
NamespaceType stringToNamespaceType(string typeStr) @safe {
  switch (typeStr) {
    case "pid":
      return NamespaceType.PID;
    case "net":
      return NamespaceType.Network;
    case "ipc":
      return NamespaceType.IPC;
    case "mnt":
      return NamespaceType.Mount;
    case "uts":
      return NamespaceType.UTS;
    case "user":
      return NamespaceType.User;
    case "cgroup":
      return NamespaceType.Cgroup;
    default:
      return cast(NamespaceType)0;
  }
}

/// Information about a single namespace
struct NamespaceInfo {
  string type;           /// Type name (pid, net, ipc, mnt, uts, user, cgroup)
  ulong inode;           /// Inode number
  string path;           /// Path to namespace file
  int refCount;          /// Reference count
  int uid;               /// Owner UID
  int gid;               /// Owner GID

  string toString() const @safe {
    return "NamespaceInfo(" ~ type ~ ", inode=" ~ to!string(inode) ~ ")";
  }
}

/// Process information with namespace details
struct ProcessInfo {
  int pid;               /// Process ID
  string command;        /// Command name
  string state;          /// Process state (S, Z, T, W, X)
  int parentPid;         /// Parent process ID
  int sessionId;         /// Session ID
  NamespaceInfo[] namespaces;  /// Associated namespaces
}

/// Namespace hierarchy information
struct NamespaceHierarchy {
  NamespaceType type;
  ulong inode;
  int[] pidList;         /// PIDs in this namespace
  int parentInode;       /// Parent namespace inode (for user ns)
  int childCount;        /// Number of child namespaces

  string toString() const @safe {
    return "NamespaceHierarchy(" ~ namespaceTypeToString(type) ~ ", inode=" ~ to!string(inode) ~ ")";
  }
}

/// UID/GID mapping for user namespace
struct IDMapping {
  uint insideId;         /// ID inside the namespace
  uint outsideId;        /// ID outside the namespace
  uint rangeSize;        /// Number of consecutive IDs to map

  string toString() const @safe {
    return "IDMapping(" ~ to!string(insideId) ~ ":" ~ to!string(outsideId) ~ ":" ~ to!string(rangeSize) ~ ")";
  }
}

/// User namespace mapping configuration
struct UserNamespaceConfig {
  IDMapping[] uidMappings;
  IDMapping[] gidMappings;
  bool denySetgroups;    /// Deny setgroups() operation if true
}

/// Mount namespace information
struct MountInfo {
  int mountId;
  int parentId;
  int majorMinor;
  string root;
  string mountPoint;
  string mountOptions;
  string[] optionalFields;
  string fsType;
  string source;
  string[] superOptions;

  string toString() const @safe {
    return "MountInfo(" ~ mountPoint ~ ", type=" ~ fsType ~ ")";
  }
}

