module uim.kubernetes.classes.service;

import uim.kubernetes;

mixin(ShowModule!());

@safe:

// Service resource
class K8SService : IK8SService {
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

  string serviceType() const {
    return spec().getString("type", "ClusterIP");
  }

  Json[] ports() const {
    return spec().getArray("ports").toArray;
  }
}