module uim.namespaces.structs.networknamespace;

/// Network namespace information
struct NetworkNamespaceInfo {
  int pid;               /// PID owning the namespace
  string[] interfaces;   /// Network interfaces in this namespace
  string[] routes;       /// Routes in this namespace
  bool hasIpv4;          /// Has IPv4 configured
  bool hasIpv6;          /// Has IPv6 configured
}

