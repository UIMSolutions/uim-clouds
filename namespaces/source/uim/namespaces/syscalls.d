/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.namespaces.syscalls;

import core.sys.posix.unistd : getpid;
import core.sys.linux.sys.syscall;
import core.sys.posix.fcntl : open, O_RDONLY, O_CLOEXEC;
import core.stdc.errno;
import std.conv : to;
import std.exception : enforce;
import std.format : format;

import uim.namespaces.types;

@trusted:

// System call numbers for Linux x86_64
enum SYS_unshare = 272;
enum SYS_setns = 308;
enum SYS_clone = 56;

/// Native system call wrapper for unshare()
int unshare(uint flags) {
  return cast(int)syscall(SYS_unshare, flags);
}

/// Native system call wrapper for setns()
int setns(int fd, int nstype) {
  return cast(int)syscall(SYS_setns, fd, nstype);
}

/// Gets the current process ID
int getPID() @safe {
  return getpid();
}

/// Creates a new namespace using unshare()
/// Returns 0 on success, -1 on error
int createNamespace(NamespaceType type) {
  uint flags = cast(uint)type;
  int result = unshare(flags);
  if (result != 0) {
    int err = errno;
    enforce(false, format("Failed to create namespace: %s", getErrorMessage(err)));
  }
  return result;
}

/// Creates multiple new namespaces using unshare()
/// Returns 0 on success, -1 on error
int createNamespaces(NamespaceType[] types) {
  uint flags = 0;
  foreach (type; types) {
    flags |= cast(uint)type;
  }
  int result = unshare(flags);
  if (result != 0) {
    int err = errno;
    enforce(false, format("Failed to create namespaces: %s", getErrorMessage(err)));
  }
  return result;
}

/// Joins an existing namespace
/// Returns 0 on success, -1 on error
int joinNamespace(int fd, NamespaceType type) {
  int result = setns(fd, cast(int)type);
  if (result != 0) {
    int err = errno;
    enforce(false, format("Failed to join namespace: %s", getErrorMessage(err)));
  }
  return result;
}

/// Opens a namespace file descriptor
/// Returns file descriptor on success, -1 on error
int openNamespace(int pid, NamespaceType type) {
  string nsPath = format("/proc/%d/ns/%s", pid, namespaceTypeToString(type));
  int fd = open(nsPath.ptr, O_RDONLY | O_CLOEXEC);
  if (fd < 0) {
    int err = errno;
    enforce(false, format("Failed to open namespace %s: %s", nsPath, getErrorMessage(err)));
  }
  return fd;
}

/// Gets error message from errno
string getErrorMessage(int err) @safe {
  switch (err) {
    case 1:
      return "Operation not permitted (EPERM)";
    case 2:
      return "No such file or directory (ENOENT)";
    case 12:
      return "Out of memory (ENOMEM)";
    case 13:
      return "Permission denied (EACCES)";
    case 22:
      return "Invalid argument (EINVAL)";
    case 28:
      return "No space left on device (ENOSPC)";
    case 38:
      return "Function not implemented (ENOSYS)";
    default:
      return "Unknown error (" ~ to!string(err) ~ ")";
  }
}

/// Checks if namespace support is available
bool isNamespaceSupportAvailable(NamespaceType type) @trusted {
  string nsPath = format("/proc/%d/ns/%s", getPID(), namespaceTypeToString(type));
  int fd = open(nsPath.ptr, O_RDONLY | O_CLOEXEC);
  if (fd < 0) {
    return false;
  }
  core.sys.posix.unistd.close(fd);
  return true;
}

/// Gets all supported namespace types on this system
NamespaceType[] getSupportedNamespaceTypes() @trusted {
  NamespaceType[] supported;
  
  if (isNamespaceSupportAvailable(NamespaceType.PID)) {
    supported ~= NamespaceType.PID;
  }
  if (isNamespaceSupportAvailable(NamespaceType.Network)) {
    supported ~= NamespaceType.Network;
  }
  if (isNamespaceSupportAvailable(NamespaceType.IPC)) {
    supported ~= NamespaceType.IPC;
  }
  if (isNamespaceSupportAvailable(NamespaceType.Mount)) {
    supported ~= NamespaceType.Mount;
  }
  if (isNamespaceSupportAvailable(NamespaceType.UTS)) {
    supported ~= NamespaceType.UTS;
  }
  if (isNamespaceSupportAvailable(NamespaceType.User)) {
    supported ~= NamespaceType.User;
  }
  if (isNamespaceSupportAvailable(NamespaceType.Cgroup)) {
    supported ~= NamespaceType.Cgroup;
  }
  
  return supported;
}
