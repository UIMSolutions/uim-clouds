/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.virtualization.config;

import std.conv : to;
import std.exception : enforce;
import std.string : startsWith;

/// Enumeration of supported hypervisors
enum HypervisorType {
  KVM,           /// Kernel-based Virtual Machine
  QEMU,          /// Quick Emulator
  Xen,           /// Xen Hypervisor
  LibvirtQEMU,   /// QEMU via libvirt
  LibvirtKVM,    /// KVM via libvirt
  VirtualBox,    /// Oracle VirtualBox
  Hyper_V        /// Microsoft Hyper-V
}

/// String representation of hypervisor type
string hypervisorTypeToString(HypervisorType type) @safe {
  switch (type) {
    case HypervisorType.KVM:
      return "kvm";
    case HypervisorType.QEMU:
      return "qemu";
    case HypervisorType.Xen:
      return "xen";
    case HypervisorType.LibvirtQEMU:
      return "qemu+unix";
    case HypervisorType.LibvirtKVM:
      return "qemu+kvm";
    case HypervisorType.VirtualBox:
      return "virtualbox";
    case HypervisorType.Hyper_V:
      return "hyperv";
    default:
      return "unknown";
  }
}

/// Parse hypervisor type from string
HypervisorType stringToHypervisorType(string typeStr) @safe {
  switch (typeStr) {
    case "kvm":
      return HypervisorType.KVM;
    case "qemu":
      return HypervisorType.QEMU;
    case "xen":
      return HypervisorType.Xen;
    case "qemu+unix":
      return HypervisorType.LibvirtQEMU;
    case "qemu+kvm":
      return HypervisorType.LibvirtKVM;
    case "virtualbox":
      return HypervisorType.VirtualBox;
    case "hyperv":
      return HypervisorType.Hyper_V;
    default:
      return HypervisorType.KVM;
  }
}

/// Virtualization daemon connection configuration
struct VirtualizationConfig {
  string endpoint;        // e.g., "qemu:///system" or "qemu+ssh://host/system"
  HypervisorType hypervisor = HypervisorType.KVM;
  string apiVersion = "v1.0";
  bool useLibvirt = true; // Use libvirt as the backend
  string username = "";
  string password = "";
  bool insecureSkipVerify = false;
  string caCertPath = "";
  int connectionTimeout = 30;
}

/// Creates a config for local KVM/QEMU system connection (default).
VirtualizationConfig defaultConfig() @safe {
  return VirtualizationConfig(
    "qemu:///system",
    HypervisorType.LibvirtKVM,
    "v1.0",
    true,
    "",
    "",
    false,
    "",
    30
  );
}

/// Creates a config for local KVM user session.
VirtualizationConfig userSessionConfig() @safe {
  return VirtualizationConfig(
    "qemu:///session",
    HypervisorType.LibvirtKVM,
    "v1.0",
    true,
    "",
    "",
    false,
    "",
    30
  );
}

/// Creates a config for remote libvirt over SSH.
VirtualizationConfig remoteSSHConfig(
  string hostname,
  string username = "root",
  HypervisorType hypervisor = HypervisorType.LibvirtKVM
) @safe {
  return VirtualizationConfig(
    "qemu+ssh://" ~ username ~ "@" ~ hostname ~ "/system",
    hypervisor,
    "v1.0",
    true,
    username,
    "",
    false,
    "",
    30
  );
}

/// Creates a config for Xen hypervisor.
VirtualizationConfig xenConfig() @safe {
  return VirtualizationConfig(
    "xen:///",
    HypervisorType.Xen,
    "v1.0",
    true,
    "",
    "",
    false,
    "",
    30
  );
}

/// Creates a config for VirtualBox.
VirtualizationConfig virtualboxConfig() @safe {
  return VirtualizationConfig(
    "vbox:///session",
    HypervisorType.VirtualBox,
    "v1.0",
    false,
    "",
    "",
    false,
    "",
    30
  );
}

/// Creates a config for Hyper-V.
VirtualizationConfig hyperVConfig(string hostname = "localhost") @safe {
  return VirtualizationConfig(
    "hyperv://" ~ hostname ~ "/",
    HypervisorType.Hyper_V,
    "v1.0",
    false,
    "",
    "",
    false,
    "",
    30
  );
}

/// Checks if endpoint is local.
bool isLocalConnection(string endpoint) @safe {
  return endpoint.startsWith("qemu:///") || endpoint.startsWith("xen:///") ||
         endpoint.startsWith("vbox:///");
}

/// Checks if endpoint is remote.
bool isRemoteConnection(string endpoint) @safe {
  return endpoint.startsWith("qemu+") || endpoint.startsWith("xen+");
}

/// Extracts hostname from remote connection string.
string getRemoteHostname(string endpoint) @safe {
  if (endpoint.startsWith("qemu+ssh://")) {
    string rest = endpoint[11 .. $];
    size_t at = rest.indexOf('@');
    if (at != size_t.max) {
      size_t slash = rest.indexOf('/', at);
      if (slash != size_t.max) {
        return rest[at + 1 .. slash];
      }
      return rest[at + 1 .. $];
    }
  }
  return "";
}

private size_t indexOf(string str, char c) @safe {
  for (size_t i = 0; i < str.length; ++i) {
    if (str[i] == c) return i;
  }
  return size_t.max;
}
