# UIM KVM Library

A D language library for working with KVM/libvirt using the uim-framework.

## Features

- Domain lifecycle management (define, start, shutdown, destroy, undefine)
- Snapshot management (list, create, revert, delete)
- Storage pool lifecycle (list, create, delete)
- Virtual network lifecycle (define, start, stop, delete)
- Autostart toggling for domains and networks
- Host/node information retrieval

## Dependencies

- `uim-framework:core` - Core UIM framework
- `uim-framework:logging` - Logging support
- `vibe-d` - HTTP client and async I/O

## Building

```bash
cd kvm
dub build
```

## Testing

```bash
cd kvm
dub build --configuration=tests
```

## Usage

```d
import uim.kvm;

void main() {
  auto cfg = defaultConfig();
  auto client = new KVMClient(cfg);

  auto domains = client.listDomains();
  foreach (d; domains) {
    writeln(d.name ~ " (" ~ d.state ~ ")");
  }
}
```

## Notes

- Transport is left as a placeholder; wire this client to libvirt (RPC, REST proxy, or custom bridge).
- Domain and network definitions are provided as JSON helpers for simplicity; adapt to XML as needed.

## License

Apache 2.0
