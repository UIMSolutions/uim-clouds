module uim.kubernetes.classes.config;

import uim.kubernetes;

@safe:
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
