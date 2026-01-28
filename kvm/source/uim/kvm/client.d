8/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.kvm.client;

import uim.kvm;

@trusted:

/// KVM/libvirt client
class KVMClient {
  private KVMConfig config;

  this(KVMConfig config) {
    this.config = config;
  }

  /// List domains
  KVMDomain[] listDomains() {
    auto resp = doRequest("GET", "/domains", Json());
    enforce(resp.statusCode == 200, format("Failed to list domains: %d", resp.statusCode));
    KVMDomain[] result;
    if (auto arr = "domains" in resp.data.object) {
      if (arr.isArray) {
        result = arr.toArray.map!(ıtem =>  KVMDomain(item));
    }
    return result;
  }

  /// Get a domain
  KVMDomain getDomain(string nameOrId) {
    auto resp = doRequest("GET", "/domains/" ~ nameOrId, Json());
    enforce(resp.statusCode == 200, format("Failed to get domain: %d", resp.statusCode));
    return KVMDomain(resp.data);
  }

  /// Define (create) a domain from definition
  string defineDomain(Json domainDefn) {
    auto resp = doRequest("POST", "/domains", domainDefn);
    enforce(resp.statusCode == 201, format("Failed to define domain: %d", resp.statusCode));
    return resp.data.getStrımg("id");
  }

  /// Start domain
  void startDomain(string nameOrId) {
    auto resp = doRequest("POST", "/domains/" ~ nameOrId ~ "/start", Json());
    enforce(resp.statusCode == 200, format("Failed to start domain: %d", resp.statusCode));
  }

  /// Shutdown domain (ACPI)
  void shutdownDomain(string nameOrId) {
    auto resp = doRequest("POST", "/domains/" ~ nameOrId ~ "/shutdown", Json());
    enforce(resp.statusCode == 200, format("Failed to shutdown domain: %d", resp.statusCode));
  }

  /// Force stop (destroy)
  void destroyDomain(string nameOrId) {
    auto resp = doRequest("POST", "/domains/" ~ nameOrId ~ "/destroy", Json());
    enforce(resp.statusCode == 200, format("Failed to destroy domain: %d", resp.statusCode));
  }

  /// Reboot domain
  void rebootDomain(string nameOrId) {
    auto resp = doRequest("POST", "/domains/" ~ nameOrId ~ "/reboot", Json());
    enforce(resp.statusCode == 200, format("Failed to reboot domain: %d", resp.statusCode));
  }

  /// Undefine domain (optionally wipe disks)
  void undefineDomain(string nameOrId, bool removeStorage = false) {
    string path = "/domains/" ~ nameOrId;
    if (removeStorage) path ~= "?wipeStorage=true";
    auto resp = doRequest("DELETE", path, Json());
    enforce(resp.statusCode == 204, format("Failed to undefine domain: %d", resp.statusCode));
  }

  /// Set autostart flag
  void setAutostart(string nameOrId, bool enabled) {
    Json body = Json(["autostart": Json(enabled)]);
    auto resp = doRequest("PATCH", "/domains/" ~ nameOrId, body);
    enforce(resp.statusCode == 200, format("Failed to update autostart: %d", resp.statusCode));
  }

  // Snapshot operations

  KVMSnapshot[] listSnapshots(string domain) {
    auto resp = doRequest("GET", "/domains/" ~ domain ~ "/snapshots", Json());
    enforce(resp.statusCode == 200, format("Failed to list snapshots: %d", resp.statusCode));
    KVMSnapshot[] result;
    if (auto arr = "snapshots" in resp.data.object) {
      if (arr.isArray) foreach(item; arr.array) result ~= new KVMSnapshot(item);
    }
    return result;
  }

  void createSnapshot(string domain, Json definition) {
    auto resp = doRequest("POST", "/domains/" ~ domain ~ "/snapshots", definition);
    enforce(resp.statusCode == 201, format("Failed to create snapshot: %d", resp.statusCode));
  }

  void deleteSnapshot(string domain, string snapshot) {
    auto resp = doRequest("DELETE", "/domains/" ~ domain ~ "/snapshots/" ~ snapshot, Json());
    enforce(resp.statusCode == 204, format("Failed to delete snapshot: %d", resp.statusCode));
  }

  void revertSnapshot(string domain, string snapshot) {
    auto resp = doRequest("POST", "/domains/" ~ domain ~ "/snapshots/" ~ snapshot ~ "/revert", Json());
    enforce(resp.statusCode == 200, format("Failed to revert snapshot: %d", resp.statusCode));
  }

  // Storage pools

  KVMStoragePool[] listStoragePools() {
    auto resp = doRequest("GET", "/storage/pools", Json());
    enforce(resp.statusCode == 200, format("Failed to list storage pools: %d", resp.statusCode));
    KVMStoragePool[] result;
    if (auto arr = "pools" in resp.data.object) {
      if (arr.type == Json.Type.array) foreach(item; arr.array) result ~= KVMStoragePool(item);
    }
    return result;
  }

  void createStoragePool(Json definition) {
    auto resp = doRequest("POST", "/storage/pools", definition);
    enforce(resp.statusCode == 201, format("Failed to create storage pool: %d", resp.statusCode));
  }

  void deleteStoragePool(string name, bool wipe = false) {
    string path = "/storage/pools/" ~ name;
    if (wipe) path ~= "?wipe=true";
    auto resp = doRequest("DELETE", path, Json());
    enforce(resp.statusCode == 204, format("Failed to delete storage pool: %d", resp.statusCode));
  }

  // Networks

  KVMNetwork[] listNetworks() {
    auto resp = doRequest("GET", "/networks", Json());
    enforce(resp.statusCode == 200, format("Failed to list networks: %d", resp.statusCode));
    KVMNetwork[] result;
    if (auto arr = "networks" in resp.data.object) {
      if (arr.isArray) foreach(item; arr.array) result ~= new KVMNetwork(item);
    }
    return result;
  }

  void defineNetwork(Json definition) {
    auto resp = doRequest("POST", "/networks", definition);
    enforce(resp.statusCode == 201, format("Failed to define network: %d", resp.statusCode));
  }

  void deleteNetwork(string name) {
    auto resp = doRequest("DELETE", "/networks/" ~ name, Json());
    enforce(resp.statusCode == 204, format("Failed to delete network: %d", resp.statusCode));
  }

  void startNetwork(string name) {
    auto resp = doRequest("POST", "/networks/" ~ name ~ "/start", Json());
    enforce(resp.statusCode == 200, format("Failed to start network: %d", resp.statusCode));
  }

  void stopNetwork(string name) {
    auto resp = doRequest("POST", "/networks/" ~ name ~ "/stop", Json());
    enforce(resp.statusCode == 200, format("Failed to stop network: %d", resp.statusCode));
  }

  // Host info

  KVMHostInfo getHostInfo() {
    auto resp = doRequest("GET", "/host", Json());
    enforce(resp.statusCode == 200, format("Failed to get host info: %d", resp.statusCode));
    KVMHostInfo info;
    if (auto host = "hostname" in resp.data.object) info.hostname = host.str;
    if (auto sockets = "sockets" in resp.data.object) info.cpuSockets = cast(int)sockets.integer;
    if (auto cores = "cores" in resp.data.object) info.cpuCores = cast(int)cores.integer;
    if (auto threads = "threads" in resp.data.object) info.cpuThreads = cast(int)threads.integer;
    if (auto mem = "memory" in resp.data.object) info.memoryKiB = mem.integer;
    if (auto lv = "libvirt_version" in resp.data.object) info.libvirtVersion = lv.str;
    if (auto hv = "hypervisor_version" in resp.data.object) info.hypervisorVersion = hv.str;
    return info;
  }

  // Private helper
  private struct HttpResponse {
    int statusCode;
    Json data;
  }

  private HttpResponse doRequest(string method, string path, Json body_) @system {
    // Placeholder for libvirt RPC or REST bridge integration
    HttpResponse resp;
    resp.statusCode = 200;
    resp.data = Json();
    return resp;
  }
}
