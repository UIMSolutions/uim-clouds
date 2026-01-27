# Virtualization Library Examples

## Basic VM Operations

```d
import uim.virtualization;

void main() {
  // Create a client with default KVM configuration
  auto config = defaultConfig();
  auto client = new VirtualizationClient(config);
  
  // List all virtual machines
  auto vms = client.listVirtualMachines(true);  // true = include inactive
  foreach(vm; vms) {
    writefln("VM: %s (State: %s)", vm.name, vm.state);
  }
}
```

## Getting VM Information

```d
import uim.virtualization;

void main() {
  auto config = defaultConfig();
  auto client = new VirtualizationClient(config);
  
  // Get specific VM
  auto vm = client.getVirtualMachine("my-vm");
  writefln("VM: %s", vm.name);
  writefln("  vCPUs: %d", vm.vCpuCount);
  writefln("  Memory: %d MB", vm.memoryMB);
  writefln("  State: %s", vm.state);
  
  // Get detailed state
  auto state = client.getVirtualMachineState("my-vm");
  writefln("  Status: %s", state.state);
}
```

## Creating a Virtual Machine

```d
import uim.virtualization;

void main() {
  auto config = defaultConfig();
  auto client = new VirtualizationClient(config);
  
  // Create VM configuration
  auto vmConfig = createVMConfig("ubuntu-vm", 4, 4096, "linux");
  
  // Add disk
  auto diskConfig = createVMDiskConfig(
    "/var/lib/libvirt/images/ubuntu-vm.qcow2",
    "vda",
    "disk",
    "qcow2"
  );
  
  // Add network interface
  auto nicConfig = createVMNICConfig("default", "virtio");
  
  // Create the VM
  string vmId = client.createVirtualMachine("ubuntu-vm", vmConfig);
  writefln("Created VM with ID: %s", vmId);
  
  // Start the VM
  client.startVirtualMachine("ubuntu-vm");
  writeln("VM started");
}
```

## VM Lifecycle Management

```d
import uim.virtualization;

void main() {
  auto config = defaultConfig();
  auto client = new VirtualizationClient(config);
  
  // Start VM
  client.startVirtualMachine("my-vm");
  
  // Pause VM
  client.pauseVirtualMachine("my-vm");
  
  // Resume VM
  client.resumeVirtualMachine("my-vm");
  
  // Reboot VM
  client.rebootVirtualMachine("my-vm");
  
  // Stop VM
  client.stopVirtualMachine("my-vm", false);  // false = don't force
  
  // Destroy VM
  client.destroyVirtualMachine("my-vm", true);  // true = delete storage
}
```

## Working with Disks

```d
import uim.virtualization;

void main() {
  auto config = defaultConfig();
  auto client = new VirtualizationClient(config);
  
  // List attached disks
  auto disks = client.listVirtualDisks("my-vm");
  foreach(disk; disks) {
    writefln("Disk: %s (%s)", disk.name, disk.format);
    writefln("  Size: %s", formatMemorySize(disk.sizeBytes));
    writefln("  Target: %s", disk.targetDevice);
  }
  
  // Attach a new disk
  auto newDiskConfig = createVMDiskConfig(
    "/var/lib/libvirt/images/data.qcow2",
    "vdb",
    "disk",
    "qcow2"
  );
  client.attachDisk("my-vm", newDiskConfig);
  
  // Detach a disk
  client.detachDisk("my-vm", "vdb");
}
```

## Managing Network Interfaces

```d
import uim.virtualization;

void main() {
  auto config = defaultConfig();
  auto client = new VirtualizationClient(config);
  
  // List network interfaces
  auto nics = client.listVirtualNICs("my-vm");
  foreach(nic; nics) {
    writefln("NIC: %s", nic.macAddress);
    writefln("  Network: %s", nic.networkName);
    writefln("  IP: %s", nic.ipAddress);
  }
  
  // Add new network interface
  auto nicConfig = createVMNICConfig("secondary-network", "virtio");
  client.attachNIC("my-vm", nicConfig);
  
  // Remove network interface
  client.detachNIC("my-vm", "52:54:00:11:22:33");
}
```

## Snapshots

```d
import uim.virtualization;

void main() {
  auto config = defaultConfig();
  auto client = new VirtualizationClient(config);
  
  // Create a snapshot
  string snapshotId = client.createSnapshot(
    "my-vm",
    "before-update",
    "Snapshot before system update"
  );
  writefln("Created snapshot: %s", snapshotId);
  
  // List snapshots
  auto snapshots = client.listSnapshots("my-vm");
  foreach(snapshot; snapshots) {
    writefln("Snapshot: %s (created: %d)", snapshot.name, snapshot.createdAt);
  }
  
  // Revert to snapshot
  client.revertToSnapshot("my-vm", "before-update");
  writeln("Reverted to snapshot");
  
  // Delete snapshot
  client.deleteSnapshot("my-vm", "before-update");
}
```

## Storage Pools and Volumes

```d
import uim.virtualization;

void main() {
  auto config = defaultConfig();
  auto client = new VirtualizationClient(config);
  
  // Create storage pool
  auto poolConfig = createDirStoragePoolConfig(
    "local-storage",
    "/var/lib/libvirt/images"
  );
  string poolId = client.createStoragePool("local-storage", poolConfig);
  
  // List storage pools
  auto pools = client.listStoragePools();
  foreach(pool; pools) {
    writefln("Pool: %s (Type: %s)", pool.name, pool.type);
    writefln("  Capacity: %s", formatMemorySize(pool.capacityBytes));
    writefln("  Available: %s", formatMemorySize(pool.availableBytes));
  }
  
  // Create storage volume
  auto volConfig = createStorageVolumeConfig("my-disk", 100_000_000_000, "qcow2");
  string volId = client.createStorageVolume("local-storage", volConfig);
  
  // List volumes
  auto volumes = client.listStorageVolumes("local-storage");
  foreach(vol; volumes) {
    writefln("Volume: %s", vol.name);
  }
  
  // Delete volume
  client.deleteStorageVolume("local-storage", "my-disk");
}
```

## Virtual Networks

```d
import uim.virtualization;

void main() {
  auto config = defaultConfig();
  auto client = new VirtualizationClient(config);
  
  // Create NAT network
  auto natNetConfig = createNATNetworkConfig(
    "private-network",
    "192.168.100.0/24",
    true
  );
  string netId = client.createVirtualNetwork("private-network", natNetConfig);
  
  // Create bridged network
  auto bridgeNetConfig = createBridgedNetworkConfig(
    "bridge-network",
    "br0",
    "bridge"
  );
  client.createVirtualNetwork("bridge-network", bridgeNetConfig);
  
  // List networks
  auto networks = client.listVirtualNetworks();
  foreach(net; networks) {
    writefln("Network: %s", net.name);
    writefln("  Type: %s", net.ipv4Network);
    writefln("  Active: %s", net.isActive);
  }
  
  // Delete network
  client.deleteVirtualNetwork("private-network");
}
```

## VM Cloning

```d
import uim.virtualization;

void main() {
  auto config = defaultConfig();
  auto client = new VirtualizationClient(config);
  
  // Clone a VM
  auto cloneConfig = createCloneConfig("template-vm", "clone-vm", false, true);
  string clonedVmId = client.cloneVirtualMachine(cloneConfig);
  writefln("Cloned VM: %s", clonedVmId);
  
  // VM is now ready to use
  client.startVirtualMachine("clone-vm");
}
```

## VM Migration

```d
import uim.virtualization;

void main() {
  auto config = remoteSSHConfig("target-host.example.com", "root");
  auto client = new VirtualizationClient(config);
  
  // Create migration info
  auto migrationInfo = createMigrationInfo(
    "my-vm",
    "source-host",
    "target-host",
    "qemu+ssh://root@target-host/system",
    true  // live migration
  );
  
  // Perform migration
  client.migrateVirtualMachine(migrationInfo);
  writeln("VM migration started");
}
```

## Complete KVM VM Template

```d
import uim.virtualization;

void main() {
  auto config = defaultConfig();
  auto client = new VirtualizationClient(config);
  
  // Create a complete KVM VM
  auto vmConfig = createKVMVMTemplate(
    "ubuntu-kvm",
    4,           // vCPUs
    8192,        // Memory in MB
    "/var/lib/libvirt/images/ubuntu.qcow2",
    "default",   // Network
    "linux"      // OS type
  );
  
  string vmId = client.createVirtualMachine("ubuntu-kvm", vmConfig);
  client.startVirtualMachine("ubuntu-kvm");
}
```

## Lightweight VM

```d
import uim.virtualization;

void main() {
  auto config = defaultConfig();
  auto client = new VirtualizationClient(config);
  
  // Create a lightweight VM
  auto vmConfig = createLightweightVMTemplate("container-vm", 512, 1);
  
  string vmId = client.createVirtualMachine("container-vm", vmConfig);
}
```

## LVM Storage Pool

```d
import uim.virtualization;

void main() {
  auto config = defaultConfig();
  auto client = new VirtualizationClient(config);
  
  // Create LVM storage pool
  auto lvmPoolConfig = createLVMStoragePoolConfig(
    "lvm-pool",
    "vg0"
  );
  
  string poolId = client.createStoragePool("lvm-pool", lvmPoolConfig);
  writefln("Created LVM pool: %s", poolId);
}
```

## Remote Connection (SSH)

```d
import uim.virtualization;

void main() {
  // Connect to remote KVM host via SSH
  auto config = remoteSSHConfig("kvm-host.example.com", "libvirt");
  auto client = new VirtualizationClient(config);
  
  // All operations work the same way
  auto vms = client.listVirtualMachines();
  foreach(vm; vms) {
    writefln("Remote VM: %s", vm.name);
  }
}
```

## Xen Hypervisor

```d
import uim.virtualization;

void main() {
  // Connect to Xen hypervisor
  auto config = xenConfig();
  auto client = new VirtualizationClient(config);
  
  auto vms = client.listVirtualMachines();
}
```

## Host Capabilities

```d
import uim.virtualization;

void main() {
  auto config = defaultConfig();
  auto client = new VirtualizationClient(config);
  
  // Get host capabilities
  auto caps = client.getHostCapabilities();
  writefln("Host: %s", caps.hostname);
  writefln("CPUs: %d", caps.cpuCount);
  writefln("Memory: %s", formatMemorySize(caps.memoryBytes));
  writefln("Hypervisor: %s", caps.hypervisorType);
}
```

## Bridged Network Interface

```d
import uim.virtualization;

void main() {
  auto config = defaultConfig();
  auto client = new VirtualizationClient(config);
  
  // Attach bridged network interface to VM
  auto bridgedNic = createBridgedNICConfig("br0", "virtio");
  client.attachNIC("my-vm", bridgedNic);
}
```

## Copy-on-Write Volume

```d
import uim.virtualization;

void main() {
  auto config = defaultConfig();
  auto client = new VirtualizationClient(config);
  
  // Create a CoW volume from backing store
  auto cowVolume = createCowVolumeConfig(
    "derived-disk",
    "/var/lib/libvirt/images/base-image.qcow2"
  );
  
  string volId = client.createStorageVolume("local-storage", cowVolume);
}
```

## Validation

```d
import uim.virtualization;

void main() {
  // Validate VM name
  if (isValidVMName("my-test-vm")) {
    writeln("VM name is valid");
  }
  
  // Validate MAC address
  if (isValidMACAddress("52:54:00:aa:bb:cc")) {
    writeln("MAC address is valid");
  }
}
```

## Memory Conversions

```d
import uim.virtualization;

void main() {
  // Parse human-readable memory string
  long memoryBytes = parseMemoryString("4GB");
  writefln("4GB = %d bytes", memoryBytes);
  
  // Format bytes as human-readable string
  string formatted = formatMemorySize(4_294_967_296);
  writefln("Formatted: %s", formatted);
}
```
