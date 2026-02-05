/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.namespaces.manager;

import core.sys.posix.unistd : close;
import std.exception : enforce;
import std.format : format;

import uim.namespaces.types;
import uim.namespaces.syscalls;
import uim.namespaces.inspector;

@trusted:

/// Manages namespace lifecycle and operations
class NamespaceManager {
  private int[] openFileDescriptors;

  /// Creates a new namespace of the specified type
  void createNamespace(NamespaceType type) {
    int result = .createNamespace(type);
    enforce(result == 0, format("Failed to create namespace: %s", namespaceTypeToString(type)));
  }

  /// Creates multiple new namespaces
  void createNamespaces(NamespaceType[] types) {
    int result = .createNamespaces(types);
    enforce(result == 0, "Failed to create namespaces");
  }

  /// Joins an existing namespace
  void joinNamespace(int pid, NamespaceType type) {
    int fd = openNamespace(pid, type);
    enforce(fd >= 0, format("Failed to open namespace for PID %d", pid));
    
    int result = .joinNamespace(fd, type);
    close(fd);
    enforce(result == 0, format("Failed to join namespace: %s", namespaceTypeToString(type)));
  }

  /// Opens a namespace file descriptor (must be closed manually)
  int openNamespaceFd(int pid, NamespaceType type) {
    int fd = openNamespace(pid, type);
    if (fd >= 0) {
      openFileDescriptors ~= fd;
    }
    return fd;
  }

  /// Closes a previously opened namespace file descriptor
  void closeNamespaceFd(int fd) {
    if (fd >= 0) {
      close(fd);
      
      // Remove from tracking
      for (size_t i = 0; i < openFileDescriptors.length; ++i) {
        if (openFileDescriptors[i] == fd) {
          openFileDescriptors = openFileDescriptors[0 .. i] ~ openFileDescriptors[i + 1 .. $];
          break;
        }
      }
    }
  }

  /// Gets current process namespace information
  NamespaceInfo[] getProcessNamespaces() {
    return getProcessNamespaces(getPID());
  }

  /// Gets namespace information for a specific process
  NamespaceInfo[] getProcessNamespaces(int pid) {
    return inspector.getProcessNamespaces(pid);
  }

  /// Checks if a namespace type is supported on this system
  bool isNamespaceSupportedAvailable(NamespaceType type) {
    return isNamespaceSupportAvailable(type);
  }

  /// Gets all supported namespace types
  NamespaceType[] getSupportedNamespaces() {
    return getSupportedNamespaceTypes();
  }

  /// Gets namespace hierarchy information
  NamespaceHierarchy[] getNamespaceHierarchy() {
    return inspector.getNamespaceHierarchy();
  }

  /// Sets up user namespace with UID/GID mappings
  void setupUserNamespace(UserNamespaceConfig config) {
    // This would write to /proc/self/uid_map and /proc/self/gid_map
    // Implementation depends on the specific UID/GID mapping requirements
  }

  /// Configures PID namespace
  void configurePidNamespace() {
    // Specific PID namespace configuration
    // Such as init process setup
  }

  /// Configures network namespace
  void configureNetworkNamespace() {
    // Network namespace configuration
    // Such as loopback device setup
  }

  /// Configures mount namespace
  void configureMountNamespace() {
    // Mount namespace configuration
    // Such as pivot root operations
  }

  /// Gets mount information for current process
  MountInfo[] getMountInfo() {
    return inspector.getMountInfo();
  }

  /// Gets mount information for specific process
  MountInfo[] getMountInfo(int pid) {
    return inspector.getMountInfo(pid);
  }

  /// Gets network namespace information
  NetworkNamespaceInfo getNetworkInfo() {
    return inspector.getNetworkNamespaceInfo();
  }

  /// Gets UID mappings for user namespace
  IDMapping[] getUIDMappings() {
    return inspector.getUIDMappings();
  }

  /// Gets cgroup information
  CgroupInfo getCgroupInfo() {
    return inspector.getCgroupInfo();
  }

  /// Cleanup - closes all open file descriptors
  ~this() {
    foreach (fd; openFileDescriptors) {
      if (fd >= 0) {
        close(fd);
      }
    }
  }
}

