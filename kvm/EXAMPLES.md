# KVM Library Examples

## List Domains
```d
import uim.kvm;
import std.stdio : writefln;

void main() {
  auto client = new KVMClient(defaultConfig());
  auto domains = client.listDomains();
  foreach (d; domains) {
    writefln("Domain: %s (%s)", d.name, d.state);
  }
}
```

## Define and Start a Domain
```d
import uim.kvm;
import std.stdio : writefln;

void main() {
  auto client = new KVMClient(defaultConfig());
  auto defn = createDomainDefinition("demo-kvm", 2, 2048, "hvm", "x86_64");

  auto id = client.defineDomain(defn);
  writefln("Defined domain id: %s", id);
  client.startDomain("demo-kvm");
}
```

## Snapshots
```d
import uim.kvm;
import std.stdio : writefln;

void main() {
  auto client = new KVMClient(defaultConfig());
  auto snapDef = createSnapshotDefinition("baseline", "Before update");
  client.createSnapshot("demo-kvm", snapDef);

  auto snaps = client.listSnapshots("demo-kvm");
  foreach (s; snaps) {
    writefln("Snapshot: %s", s.name);
  }

  client.revertSnapshot("demo-kvm", "baseline");
}
```

## Storage Pools
```d
import uim.kvm;
import std.stdio : writefln;

void main() {
  auto client = new KVMClient(defaultConfig());
  auto poolDef = createStoragePoolDefinition("images", "dir", "/var/lib/libvirt/images");
  client.createStoragePool(poolDef);

  auto pools = client.listStoragePools();
  foreach (p; pools) {
    writefln("Pool: %s (%s)", p.name, p.state);
  }
}
```

## Networks
```d
import uim.kvm;
import std.stdio : writefln;

void main() {
  auto client = new KVMClient(defaultConfig());
  auto netDef = createNetworkDefinition("private-net", "nat", "virbr10");
  client.defineNetwork(netDef);
  client.startNetwork("private-net");

  auto nets = client.listNetworks();
  foreach (n; nets) {
    writefln("Network: %s (%s)", n.name, n.status);
  }

  client.stopNetwork("private-net");
  client.deleteNetwork("private-net");
}
```
