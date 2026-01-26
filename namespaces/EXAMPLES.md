# Linux Namespaces Library Examples

## Basic Namespace Information

```d
import uim.namespaces;

void main() {
  // Get current process namespaces
  int pid = getPID();
  auto namespaces = getProcessNamespaces(pid);
  
  foreach(ns; namespaces) {
    writefln("Namespace: %s, INode: %d", ns.type, ns.inode);
  }
}
```

## Checking Supported Namespaces

```d
import uim.namespaces;

void main() {
  auto supported = getSupportedNamespaceTypes();
  writeln("Supported namespaces:");
  foreach(nsType; supported) {
    writefln("  - %s", namespaceTypeToString(nsType));
    writefln("    %s", describeNamespaceType(nsType));
  }
}
```

## Creating Isolated Namespaces

```d
import uim.namespaces;

void main() {
  auto manager = createNamespaceManager();
  
  // Create a PID namespace (only in child process)
  try {
    manager.createNamespace(NamespaceType.PID);
    writeln("Created PID namespace");
  } catch (Exception e) {
    writefln("Failed to create namespace: %s", e.msg);
  }
}
```

## Creating Multiple Namespaces

```d
import uim.namespaces;

void main() {
  auto manager = createNamespaceManager();
  
  // Create container-like isolation
  try {
    auto types = getContainerNamespaces();
    manager.createNamespaces(types);
    writeln("Created complete container isolation");
  } catch (Exception e) {
    writefln("Error: %s", e.msg);
  }
}
```

## Joining an Existing Namespace

```d
import uim.namespaces;

void main() {
  auto manager = createNamespaceManager();
  
  // Join the network namespace of another process
  try {
    manager.joinNamespace(1234, NamespaceType.Network);
    writeln("Successfully joined network namespace of PID 1234");
  } catch (Exception e) {
    writefln("Failed to join namespace: %s", e.msg);
  }
}
```

## Namespace File Descriptors

```d
import uim.namespaces;
import core.sys.posix.unistd : close;

void main() {
  auto manager = createNamespaceManager();
  
  // Open namespace file descriptor
  int fd = manager.openNamespaceFd(1234, NamespaceType.Network);
  
  if (fd >= 0) {
    writefln("Opened namespace FD: %d", fd);
    
    // Use the FD for operations
    // ...
    
    // Close it
    manager.closeNamespaceFd(fd);
  }
}
```

## User Namespace Configuration

```d
import uim.namespaces;

void main() {
  // Create standard user namespace mapping
  auto config = createStandardUserNamespace(0, 0);
  
  writeln("UID Mappings:");
  foreach(mapping; config.uidMappings) {
    writefln("  %s", formatUIDMapping(mapping));
  }
  
  writeln("GID Mappings:");
  foreach(mapping; config.gidMappings) {
    writefln("  %s", formatGIDMapping(mapping));
  }
}
```

## Nested User Namespace

```d
import uim.namespaces;

void main() {
  // Create nested user namespace (for unprivileged containers)
  auto config = createNestedUserNamespace(100000, 100000, 65536);
  
  writeln("Nested namespace mappings created:");
  foreach(mapping; config.uidMappings) {
    writefln("  UID: %s", formatUIDMapping(mapping));
  }
}
```

## Mount Namespace Information

```d
import uim.namespaces;

void main() {
  auto manager = createNamespaceManager();
  
  // Get mount information for current process
  auto mounts = manager.getMountInfo();
  
  writeln("Current mounts:");
  foreach(mount; mounts) {
    writefln("  %d: %s (type: %s)", 
      mount.mountId, 
      mount.mountPoint, 
      mount.fsType
    );
  }
}
```

## Network Namespace Information

```d
import uim.namespaces;

void main() {
  auto manager = createNamespaceManager();
  
  // Get network configuration
  auto netInfo = manager.getNetworkInfo();
  
  writefln("Network Namespace:");
  writefln("  PID: %d", netInfo.pid);
  writefln("  IPv4: %s", netInfo.hasIpv4);
  writefln("  IPv6: %s", netInfo.hasIpv6);
  writefln("  Interfaces: %d", netInfo.interfaces.length);
}
```

## UID/GID Mappings

```d
import uim.namespaces;

void main() {
  auto manager = createNamespaceManager();
  
  // Get UID mappings for user namespace
  auto uidMaps = manager.getUIDMappings();
  
  writeln("UID Mappings:");
  foreach(mapping; uidMaps) {
    writefln("  Inside: %d -> Outside: %d (Range: %d)",
      mapping.insideId,
      mapping.outsideId,
      mapping.rangeSize
    );
  }
}
```

## Cgroup Information

```d
import uim.namespaces;

void main() {
  auto manager = createNamespaceManager();
  
  // Get cgroup configuration
  auto cgroupInfo = manager.getCgroupInfo();
  
  writefln("Cgroup Path: %s", cgroupInfo.path);
  writeln("Controllers:");
  foreach(controller; cgroupInfo.controllers) {
    writefln("  - %s", controller);
  }
}
```

## Namespace Hierarchy

```d
import uim.namespaces;

void main() {
  auto manager = createNamespaceManager();
  
  // Get namespace hierarchy information
  auto hierarchies = manager.getNamespaceHierarchy();
  
  writeln("Namespace Hierarchies:");
  foreach(h; hierarchies) {
    writefln("  Type: %s (Inode: %d)", 
      namespaceTypeToString(h.type),
      h.inode
    );
    writefln("    Processes: %d", h.pidList.length);
  }
}
```

## Minimal Isolation

```d
import uim.namespaces;

void main() {
  auto manager = createNamespaceManager();
  
  try {
    // Create minimal process isolation
    auto types = getMinimalNamespaces();
    manager.createNamespaces(types);
    
    writeln("Minimal isolation created:");
    foreach(t; types) {
      writefln("  - %s", namespaceTypeToString(t));
    }
  } catch (Exception e) {
    writefln("Error: %s", e.msg);
  }
}
```

## Network Isolation

```d
import uim.namespaces;

void main() {
  auto manager = createNamespaceManager();
  
  try {
    // Create network-focused isolation
    auto types = getNetworkIsolationNamespaces();
    manager.createNamespaces(types);
    
    writeln("Network isolation created");
  } catch (Exception e) {
    writefln("Error: %s", e.msg);
  }
}
```

## Custom ID Mapping

```d
import uim.namespaces;

void main() {
  // Create custom UID/GID mappings
  IDMapping[] uidMappings;
  uidMappings ~= createIDMapping(0, 0, 1);        // Root maps to host root
  uidMappings ~= createIDMapping(1, 100000, 65535); // Regular users
  
  writeln("Custom UID mappings:");
  foreach(mapping; uidMappings) {
    writefln("  %s", formatUIDMapping(mapping));
  }
}
```

## Process Namespace Inspection

```d
import uim.namespaces;

void main() {
  auto manager = createNamespaceManager();
  
  // Get detailed namespace information for a process
  auto namespaces = manager.getProcessNamespaces(1234);
  
  foreach(ns; namespaces) {
    writefln("Namespace Info:");
    writefln("  Type: %s", ns.type);
    writefln("  Inode: %d", ns.inode);
    writefln("  Path: %s", ns.path);
  }
}
```

## Container Setup

```d
import uim.namespaces;

void main() {
  auto manager = createNamespaceManager();
  
  try {
    // Create full container isolation
    auto types = getContainerNamespaces();
    manager.createNamespaces(types);
    
    // Create user namespace mapping
    auto userConfig = createNestedUserNamespace(100000, 100000, 65536);
    manager.setupUserNamespace(userConfig);
    
    // Configure networks
    manager.configureNetworkNamespace();
    
    writeln("Container environment ready");
  } catch (Exception e) {
    writefln("Setup error: %s", e.msg);
  }
}
```

## Capability Requirements

```d
import uim.namespaces;

void main() {
  // Check which capabilities are needed
  auto pidCaps = getRequiredCapabilities(NamespaceType.PID);
  auto netCaps = getRequiredCapabilities(NamespaceType.Network);
  auto userCaps = getRequiredCapabilities(NamespaceType.User);
  
  writeln("Required capabilities for PID namespace:", pidCaps);
  writeln("Required capabilities for Network namespace:", netCaps);
  writeln("Required capabilities for User namespace:", userCaps);
}
```

## Namespace Description

```d
import uim.namespaces;

void main() {
  auto types = getSupportedNamespaceTypes();
  
  writeln("=== Linux Namespaces ===\n");
  foreach(type; types) {
    writefln("%s:", namespaceTypeToString(type));
    writefln("  %s\n", describeNamespaceType(type));
  }
}
```

## Mount Options

```d
import uim.namespaces;

void main() {
  // Create mount options for namespace
  auto opts = createMountOptions(["rbind", "rprivate"]);
  writefln("Mount options: %s", opts);
}
```

## Default Cgroup Configuration

```d
import uim.namespaces;

void main() {
  auto cgroupConfig = getDefaultCgroupConfig();
  
  writefln("Default Cgroup Path: %s", cgroupConfig.path);
  writeln("Default Controllers:");
  foreach(controller; cgroupConfig.controllers) {
    writefln("  - %s", controller);
  }
}
```
