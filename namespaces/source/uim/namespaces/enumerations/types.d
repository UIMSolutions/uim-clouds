module uim.namespaces.enumerations.types;

/// Enumeration of Linux namespace types
enum NamespaceType {
  PID = 0x20000000,      /// Process ID namespace
  Network = 0x40000000,  /// Network namespace
  IPC = 0x08000000,      /// Inter-process communication namespace
  Mount = 0x00020000,    /// Mount filesystem namespace
  UTS = 0x04000000,      /// UTS (hostname/domain) namespace
  User = 0x10000000,     /// User and group ID namespace
  Cgroup = 0x02000000    /// Cgroup namespace
}
