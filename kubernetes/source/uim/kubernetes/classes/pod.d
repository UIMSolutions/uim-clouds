module uim.kubernetes.classes.pod;

import uim.kubernetes;

mixin(ShowModule!());

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
    return status().getString("phase", "Unknown");
  }

  Json[] containerStatuses() const @trusted {
    return status().getArray("containerStatuses").toArray;
  }
}