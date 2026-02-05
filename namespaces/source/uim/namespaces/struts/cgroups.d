module uim.namespaces.structs.cgroup;

import uim.namespaces;
@safe:

/// Cgroup information for a namespace
struct CgroupInfo {
  string path;           /// Cgroup path
  string[] controllers;  /// Enabled controllers
  string memoryLimit;    /// Memory limit (if set)
  string cpuLimit;       /// CPU limit (if set)
  string pidLimit;       /// PID limit (if set)
}
