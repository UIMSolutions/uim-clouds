# UIM Linux Namespaces Library

A D language library for working with Linux namespaces using the uim-framework.

## Features

- PID namespace management (process isolation)
- Network namespace management (network isolation)
- IPC namespace management (inter-process communication isolation)
- Mount namespace management (filesystem isolation)
- UTS namespace management (hostname/domain isolation)
- User namespace management (UID/GID mapping)
- Cgroup namespace management (cgroup isolation)
- Process namespace tracking and inspection
- Namespace joining and creation
- Resource monitoring per namespace

## Dependencies

- `uim-framework:core` - Core UIM framework
- `uim-framework:logging` - Logging support

## Building

```bash
dub build
```

## Testing

```bash
dub build --configuration=tests
```

## Usage

```d
import uim.namespaces;

void main() {
  // Get current process namespaces
  auto pid = getPID();
  auto namespaces = getProcessNamespaces(pid);
  
  foreach(ns; namespaces) {
    writefln("Namespace: %s, INode: %d", ns.type, ns.inode);
  }
}
```

## Namespace Types

- **PID**: Process ID isolation
- **Network**: Network interface and routing isolation
- **IPC**: System V IPC object isolation
- **Mount**: Filesystem mount isolation
- **UTS**: Hostname and domain name isolation
- **User**: User and group ID isolation
- **Cgroup**: Cgroup hierarchy isolation

## Linux Requirements

This library requires Linux kernel with namespace support. Ensure the following are available:

- `/proc/<pid>/ns/` directory
- `unshare()`, `setns()`, `clone()` system calls
- Appropriate capabilities (usually CAP_SYS_ADMIN)

## License

Apache 2.0
