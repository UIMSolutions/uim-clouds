# UIM Virtualization Library

A D language library for working with virtualization (KVM, QEMU, Xen) using the uim-framework.

## Features

- Virtual machine management (list, create, start, stop, destroy)
- Hypervisor support (KVM, QEMU, Xen)
- VM lifecycle management (pause, resume, reboot)
- Snapshots and cloning
- Storage pool and volume management
- Virtual network management
- Guest agent communication
- VM monitoring and statistics
- Migration support (live migration)
- VM templates and provisioning
- Console/serial port access

## Dependencies

- `uim-framework:core` - Core UIM framework
- `uim-framework:logging` - Logging support
- `vibe-d` - HTTP client and async I/O

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
import uim.virtualization;

void main() {
  auto config = defaultConfig();
  auto client = new VirtualizationClient(config);
  
  auto vms = client.listVirtualMachines();
  foreach(vm; vms) {
    writeln(vm.name);
  }
}
```

## Supported Hypervisors

- KVM (Kernel-based Virtual Machine)
- QEMU (Quick Emulator)
- Xen (Xen Hypervisor)
- Generic libvirt interface

## License

Apache 2.0
