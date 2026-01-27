# LXC Library Examples

## Basic Container Operations

```d
import uim.lxc;

void main() {
  // Create a client with default configuration (Unix socket)
  auto config = defaultConfig();
  auto client = new LXCClient(config);
  
  // List all containers
  auto containers = client.listContainers();
  foreach(container; containers) {
    writefln("Container: %s (Status: %s)", container.name, container.status);
  }
}
```

## Getting Container Information

```d
import uim.lxc;

void main() {
  auto config = defaultConfig();
  auto client = new LXCClient(config);
  
  // Get specific container
  auto container = client.getContainer("my-container");
  writefln("Container: %s", container.name);
  
  // Get detailed state
  auto state = client.getContainerState("my-container");
  writefln("Status: %s, PID: %s", state.status, state.pid);
}
```

## Creating and Managing Containers

```d
import uim.lxc;
import std.json : Json;

void main() {
  auto config = defaultConfig();
  auto client = new LXCClient(config);
  
  // Create container from image
  auto containerConfig = createContainerFromImage(
    "ubuntu/22.04",
    ["LOG_LEVEL": "debug"],
    ["app": "myapp"]
  );
  
  // Create the container
  string operationId = client.createContainer("my-container", containerConfig);
  writefln("Creating container with operation ID: %s", operationId);
  
  // Wait for operation to complete
  client.waitOperation(operationId, 60);
  
  // Start the container
  operationId = client.startContainer("my-container");
  client.waitOperation(operationId);
  
  // Get container info
  auto container = client.getContainer("my-container");
  writefln("Container %s is in state: %s", container.name, container.status);
  
  // Stop the container
  operationId = client.stopContainer("my-container", 30);
  client.waitOperation(operationId);
  
  // Remove the container
  operationId = client.removeContainer("my-container");
  client.waitOperation(operationId);
}
```

## Container State Management

```d
import uim.lxc;

void main() {
  auto config = defaultConfig();
  auto client = new LXCClient(config);
  
  // Start a container
  auto opId = client.startContainer("my-container");
  client.waitOperation(opId);
  
  // Freeze the container (pause all processes)
  opId = client.freezeContainer("my-container");
  client.waitOperation(opId);
  
  // Unfreeze the container
  opId = client.unfreezeContainer("my-container");
  client.waitOperation(opId);
  
  // Restart the container
  opId = client.restartContainer("my-container", 10);
  client.waitOperation(opId);
  
  // Stop the container
  opId = client.stopContainer("my-container", 30, false);
  client.waitOperation(opId);
}
```

## Working with Snapshots

```d
import uim.lxc;

void main() {
  auto config = defaultConfig();
  auto client = new LXCClient(config);
  
  // Create a snapshot of a container
  string opId = client.createSnapshot(
    "my-container",
    "before-update",
    "Snapshot before package update"
  );
  client.waitOperation(opId);
  
  // List all snapshots
  auto snapshots = client.listSnapshots("my-container");
  foreach(snapshot; snapshots) {
    writefln("Snapshot: %s (created: %d)", snapshot.name, snapshot.createdAt);
  }
  
  // Restore a snapshot
  opId = client.restoreSnapshot("my-container", "before-update");
  client.waitOperation(opId);
  
  // Remove a snapshot
  opId = client.removeSnapshot("my-container", "before-update");
  client.waitOperation(opId);
}
```

## Network Management

```d
import uim.lxc;

void main() {
  auto config = defaultConfig();
  auto client = new LXCClient(config);
  
  // Create a bridge network
  auto networkConfig = createBridgeNetworkConfig(
    "lxdbr0",
    "10.0.0.1/24",
    "true"
  );
  
  string opId = client.createNetwork("lxdbr0", networkConfig);
  client.waitOperation(opId);
  
  // List all networks
  auto networks = client.listNetworks();
  foreach(network; networks) {
    writefln("Network: %s (Type: %s)", network.name, network.type);
  }
  
  // Get network info
  auto network = client.getNetwork("lxdbr0");
  writefln("Network %s members: %d", network.name, network.members.length);
  
  // Remove a network
  opId = client.removeNetwork("lxdbr0");
  client.waitOperation(opId);
}
```

## Storage Pool Management

```d
import uim.lxc;

void main() {
  auto config = defaultConfig();
  auto client = new LXCClient(config);
  
  // Create a directory-based storage pool
  auto storageConfig = createDirStoragePoolConfig("local", "/var/lib/lxc/storage");
  string opId = client.createStoragePool("local", storageConfig);
  client.waitOperation(opId);
  
  // Or create an LVM-based storage pool
  auto lvmConfig = createLVMStoragePoolConfig("lvm-pool", "vg0");
  opId = client.createStoragePool("lvm-pool", lvmConfig);
  client.waitOperation(opId);
  
  // Or create a ZFS-based storage pool
  auto zfsConfig = createZFSStoragePoolConfig("zfs-pool", "pool/lxc");
  opId = client.createStoragePool("zfs-pool", zfsConfig);
  client.waitOperation(opId);
  
  // List all storage pools
  auto pools = client.listStoragePools();
  foreach(pool; pools) {
    writefln("Pool: %s (Driver: %s)", pool.name, pool.driver);
  }
  
  // Get pool info
  auto pool = client.getStoragePool("local");
  writefln("Pool %s source: %s", pool.name, pool.source);
}
```

## Container with Custom Configuration

```d
import uim.lxc;

void main() {
  auto config = defaultConfig();
  auto client = new LXCClient(config);
  
  // Combine multiple configurations
  auto basicConfig = createContainerFromImage("ubuntu/22.04");
  auto cpuConfig = createCPULimitsConfig(50);
  auto memConfig = createMemoryLimitsConfig(536_870_912, 1_073_741_824);
  auto securityConfig = createSecurityConfig(false);
  
  auto finalConfig = mergeConfigs(basicConfig, cpuConfig, memConfig, securityConfig);
  
  string opId = client.createContainer("limited-container", finalConfig);
  client.waitOperation(opId);
  
  // Start it
  opId = client.startContainer("limited-container");
  client.waitOperation(opId);
}
```

## Working with Images

```d
import uim.lxc;

void main() {
  auto config = defaultConfig();
  auto client = new LXCClient(config);
  
  // List available images
  auto images = client.listImages();
  foreach(image; images) {
    writefln("Image: %s", image.name);
  }
  
  // Get image information
  auto image = client.getImage("ubuntu/22.04");
  writefln("Image size: %d bytes", image.size);
}
```

## Container Logs

```d
import uim.lxc;

void main() {
  auto config = defaultConfig();
  auto client = new LXCClient(config);
  
  // Get container logs
  auto logs = client.getContainerLogs("my-container");
  writeln(logs.output);
}
```

## HTTPS Connection with Client Certificates

```d
import uim.lxc;

void main() {
  // For HTTPS with client certificates
  auto config = httpsConfig(
    "lxc.example.com",
    8443,
    "/path/to/ca.crt",
    "/path/to/client.crt",
    "/path/to/client.key"
  );
  
  auto client = new LXCClient(config);
  auto containers = client.listContainers();
}
```

## HTTP Connection

```d
import uim.lxc;

void main() {
  // For HTTP connection (usually for local testing)
  auto config = httpConfig("127.0.0.1", 8080);
  
  auto client = new LXCClient(config);
}
```

## Operation Monitoring

```d
import uim.lxc;

void main() {
  auto config = defaultConfig();
  auto client = new LXCClient(config);
  
  // Perform an operation and get its ID
  string opId = client.startContainer("my-container");
  
  // Check operation status
  auto operation = client.getOperation(opId);
  writefln("Operation: %s (Status: %s)", operation.id, operation.status);
  
  // Wait for it to complete (with 5 minute timeout)
  bool completed = client.waitOperation(opId, 300);
  writefln("Operation completed: %s", completed);
}
```

## Container Configuration with Devices

```d
import uim.lxc;

void main() {
  auto config = defaultConfig();
  auto client = new LXCClient(config);
  
  // Create a container with device passthrough
  auto deviceConfig = createDeviceConfig("unix-char", "/dev/kvm", "/dev/kvm");
  
  // This can be merged with other configs when creating the container
  auto containerConfig = createContainerFromImage("ubuntu/22.04");
  
  // You would merge these when creating the container
  string opId = client.createContainer("kvm-container", containerConfig);
  client.waitOperation(opId);
}
```
