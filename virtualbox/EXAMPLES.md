# VirtualBox Library Examples

## List VMs
```d
import uim.virtualbox;
import std.stdio : writefln;

void main() {
  auto client = new VirtualBoxClient(defaultConfig());
  auto vms = client.listVMs();
  foreach(vm; vms) {
    writefln("VM: %s (%s)", vm.name, vm.state);
  }
}
```

## Create and Start a VM
```d
import uim.virtualbox;
import std.stdio : writefln;

void main() {
  auto client = new VirtualBoxClient(defaultConfig());

  // Build definition
  auto defn = createVMDefinition("demo-vm", 2, 2048, "Ubuntu_64");

  // Create and start headless
  auto vmId = client.createVM("demo-vm", defn);
  client.startVM(vmId, true);
}
```

## Snapshots
```d
import uim.virtualbox;
import std.stdio : writefln;

void main() {
  auto client = new VirtualBoxClient(defaultConfig());
  auto snapId = client.createSnapshot("demo-vm", "before-upgrade", "Prep state");
  auto snaps = client.listSnapshots("demo-vm");
  foreach(s; snaps) {
    writefln("Snapshot: %s", s.name);
  }
  client.restoreSnapshot("demo-vm", "before-upgrade");
}
```

## Storage Attachments
```d
import uim.virtualbox;
import std.stdio : writefln;

void main() {
  auto client = new VirtualBoxClient(defaultConfig());
  auto disk = createStorageAttachment("SATA", "0", "0", "/var/vms/disk.qcow2", "hdd");
  client.attachStorage("demo-vm", disk);

  auto iso = createStorageAttachment("IDE", "1", "0", "/iso/installer.iso", "dvd");
  client.attachStorage("demo-vm", iso);
}
```

## Network Adapters
```d
import uim.virtualbox;
import std.stdio : writefln;

void main() {
  auto client = new VirtualBoxClient(defaultConfig());
  auto nic = createNIC("1", "bridged", "br0", "virtio");
  client.attachNIC("demo-vm", nic);
}
```

## Headless Stop and Remove
```d
import uim.virtualbox;

void main() {
  auto client = new VirtualBoxClient(defaultConfig());
  client.stopVM("demo-vm");
  client.removeVM("demo-vm", true); // delete disks
}
```
