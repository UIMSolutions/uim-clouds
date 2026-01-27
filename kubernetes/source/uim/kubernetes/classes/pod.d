module uim.kubernetes.classes.pod;

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