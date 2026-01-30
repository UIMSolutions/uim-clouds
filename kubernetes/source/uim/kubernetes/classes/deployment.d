module uim.kubernetes.classes.deployment;

import uim.kubernetes;

mixin(ShowModule!());

@safe:
// Deployment resource
class K8SDeployment {
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
