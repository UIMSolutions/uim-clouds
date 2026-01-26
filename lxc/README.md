# UIM LXC Library

A D language library for working with LXC (Linux Containers) using the uim-framework.

## Features

- LXC API client with vibe.d
- Container management (list, create, start, stop, remove)
- Container state management (pause, resume, freeze, unfreeze)
- Image/Template operations
- Network management and configuration
- Storage pools and volumes
- Container snapshots
- Console access and logs
- Device management

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
import uim.lxc;

void main() {
  auto config = defaultConfig();
  auto client = new LXCClient(config);
  
  auto containers = client.listContainers();
  foreach(container; containers) {
    writeln(container.name);
  }
}
```

## API Version

Default LXC API version: v1.0

LXC provides a RESTful API for managing containers via Unix socket or HTTP.

## License

Apache 2.0
