/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.kubernetes.resources;

import std.json : Json, JSONType;

// Common Kubernetes resource wrapper
struct KubernetesResource {
  Json data;

  string name() const @trusted {
    if (auto meta = "metadata" in data.object) {
      if (auto n = "name" in meta.object) {
        return n.str;
      }
    }
    return "";
  }

  string namespace_() const @trusted {
    if (auto meta = "metadata" in data.object) {
      if (auto ns = "namespace" in meta.object) {
        return ns.str;
      }
    }
    return "default";
  }

  string kind() const @trusted {
    if (auto k = "kind" in data.object) {
      return k.str;
    }
    return "";
  }

  string apiVersion() const @trusted {
    if (auto v = "apiVersion" in data.object) {
      return v.str;
    }
    return "v1";
  }

  Json metadata() const @trusted {
    if (auto m = "metadata" in data.object) {
      return *m;
    }
    return Json.object;
  }

  Json spec() const @trusted {
    if (auto s = "spec" in data.object) {
      return *s;
    }
    return Json.object;
  }

  Json status() const @trusted {
    if (auto st = "status" in data.object) {
      return *st;
    }
    return Json.object;
  }
}

// Pod resource
struct Pod {
  KubernetesResource resource;

  string name() const {
    return resource.name();
  }

  string namespace_() const {
    return resource.namespace_();
  }

  Json spec() const {
    return resource.spec();
  }

  Json status() const {
    return resource.status();
  }

  string phase() const @trusted {
    if (auto p = "phase" in status().object) {
      return p.str;
    }
    return "Unknown";
  }

  Json[] containerStatuses() const @trusted {
    if (auto cs = "containerStatuses" in status().object) {
      if (cs.type == Json.Type.array) {
        return cs.array;
      }
    }
    return [];
  }
}

// Deployment resource
struct Deployment {
  KubernetesResource resource;

  string name() const {
    return resource.name();
  }

  string namespace_() const {
    return resource.namespace_();
  }

  Json spec() const {
    return resource.spec();
  }

  Json status() const {
    return resource.status();
  }

  size_t desiredReplicas() const @trusted {
    if (auto r = "replicas" in spec().object) {
      if (r.type == Json.Type.integer) {
        return cast(size_t) r.integer;
      }
    }
    return 0;
  }

  size_t readyReplicas() const @trusted {
    if (auto rr = "readyReplicas" in status().object) {
      if (rr.type == Json.Type.integer) {
        return cast(size_t) rr.integer;
      }
    }
    return 0;
  }

  size_t updatedReplicas() const @trusted {
    if (auto ur = "updatedReplicas" in status().object) {
      if (ur.type == Json.Type.integer) {
        return cast(size_t) ur.integer;
      }
    }
    return 0;
  }
}

// Service resource
struct Service {
  KubernetesResource resource;

  string name() const {
    return resource.name();
  }

  string namespace_() const {
    return resource.namespace_();
  }

  Json spec() const {
    return resource.spec();
  }

  string serviceType() const @trusted {
    if (auto t = "type" in spec().object) {
      return t.str;
    }
    return "ClusterIP";
  }

  Json[] ports() const @trusted {
    if (auto p = "ports" in spec().object) {
      if (p.type == Json.Type.array) {
        return p.array;
      }
    }
    return [];
  }
}

// ConfigMap resource
struct ConfigMap {
  KubernetesResource resource;

  string name() const {
    return resource.name();
  }

  string namespace_() const {
    return resource.namespace_();
  }

  Json data() const @trusted {
    if (auto d = "data" in resource.data.object) {
      return *d;
    }
    return Json.object;
  }

  string get(string key) const @trusted {
    if (auto v = key in data().object) {
      return v.str;
    }
    return "";
  }
}
