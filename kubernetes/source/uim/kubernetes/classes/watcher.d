/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.kubernetes.classes.watcher;

import uim.kubernetes;

mixin(ShowModule!());

@safe:

/// Represents an event from a Kubernetes watch stream.
struct WatchEvent {
  string type;  // ADDED, MODIFIED, DELETED, ERROR
  Json object;
}

/// Watches a Kubernetes resource stream.
class K8SWatcher {
  private K8SClient _client;
  private string _path;
  private bool _closed = false;

  this(K8SClient client, string path) {
    _client = client;
    _path = path;
  }

  /// Gets the next event from the watch stream.
  bool next(out WatchEvent event) {
    if (_closed) {
      return false;
    }

    // Simplified: In real implementation, we'd keep an open connection.
    // For now, return false to indicate stream end.
    _closed = true;
    return false;
  }

  IK8SWatcher close() {
    _closed = true;
    return this;
  }
}
