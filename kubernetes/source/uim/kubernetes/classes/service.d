module uim.kubernetes.classes.service;

// Service resource
class K8SService {
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