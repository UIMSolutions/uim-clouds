/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.kubernetes.classes.watch;

import uim.kubernetes;

@trusted:

/// Represents an event from a Kubernetes watch stream.
struct WatchEvent {
  string type;  // ADDED, MODIFIED, DELETED, ERROR
  Json object;
}

/// Watches a Kubernetes resource stream.
class K8SWatcher {
  private K8SClient client;
  private string path;
  private bool closed = false;

  this(K8SClient client, string path) {
    this.client = client;
    this.path = path;
  }

  /// Gets the next event from the watch stream.
  bool next(out WatchEvent event) {
    if (closed) {
      return false;
    }

    // Simplified: In real implementation, we'd keep an open connection.
    // For now, return false to indicate stream end.
    closed = true;
    return false;
  }

  void close() {
    closed = true;
  }
}
