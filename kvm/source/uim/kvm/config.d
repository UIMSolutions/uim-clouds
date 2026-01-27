/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.kvm.config;

import std.conv : to;

/// Configuration for KVM/libvirt connections
struct KVMConfig {
  string uri = "qemu:///system";    // libvirt URI
  string username = "";             // sasl user if required
  string password = "";             // sasl password
  string certFile = "";             // client cert path (TLS)
  string keyFile = "";              // client key path (TLS)
  string caFile = "";               // CA bundle path (TLS)
  bool verifyTLS = true;
  int timeoutSeconds = 30;
}

/// Default system libvirt
KVMConfig defaultConfig() @safe {
  return KVMConfig();
}

/// User session libvirt
KVMConfig sessionConfig() @safe {
  KVMConfig cfg;
  cfg.uri = "qemu:///session";
  return cfg;
}

/// Remote TLS connection helper
KVMConfig remoteTLSConfig(string host, ushort port = 16514, bool verifyTLS = true) @safe {
  KVMConfig cfg;
  cfg.uri = "qemu+tls://" ~ host ~ ":" ~ port.to!string ~ "/system";
  cfg.verifyTLS = verifyTLS;
  return cfg;
}
