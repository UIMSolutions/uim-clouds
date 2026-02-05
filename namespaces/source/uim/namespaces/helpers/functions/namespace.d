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

