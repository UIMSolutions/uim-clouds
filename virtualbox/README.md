# UIM VirtualBox Library

A D language library for working with Oracle VirtualBox using the uim-framework.

## Features

- Virtual machine lifecycle (list, create, start, stop, pause, resume)
- Snapshots (create, list, restore, delete)
- Storage attachments (virtual disks, ISOs)
- Network adapters (NAT, bridged, host-only)
- Host information and guest properties
- Headless and GUI launch support
- Appliance import/export helpers

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
import uim.virtualbox;

void main() {
  auto config = defaultConfig();
  auto client = new VirtualBoxClient(config);

  auto vms = client.listVMs();
  foreach(vm; vms) {
    writeln(vm.name);
  }
}
```

## License

Apache 2.0
