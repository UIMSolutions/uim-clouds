module uim.namesapces.helpers.functions.namespace;

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

