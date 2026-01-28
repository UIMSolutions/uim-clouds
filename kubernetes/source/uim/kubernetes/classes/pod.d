module uim.kubernetes.classes.pod;

import uim.kubernetes;
@safe:
// Pod resource
class K8SPod {
  K8SResource resource;

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
      return p.to!string;
    }
    return "Unknown";
  }

  Json[] containerStatuses() const @trusted {
    if (auto cs = "containerStatuses" in status().object) {
      if (cs.isArray) {
        return cs.array;
      }
    }
    return null;
  }
}