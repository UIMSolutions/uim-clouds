module uim.kubernetes.classes.resource;

import uim.kubernetes;

mixin(ShowModule!());

@safe:
// Common Kubernetes resource wrapper
class K8SResource : IK8SResource{
  this() {
    _data = Json.emptyObject;
  }
  protected Json _data;

  Json data() const @trusted {
    return _data;
  }

  IK8SResource data(Json value) @trusted {
    _data = value;
    return this;
  }

  string name() const @trusted {
    if (auto meta = "metadata" in data.object) {
      if (auto n = "name" in meta.object) {
        return n.toString;
      }
    }
    return "";
  }

  string namespace_() const @trusted {
    if (data.hasKey("metadata")) {
      auto meta = data["metadata"];
      if (auto ns = "namespace" in meta.object) {
        return ns.toString;
      }
    }
    return "default";
  }

  string kind() const @trusted {
    if (auto k = "kind" in data.object) {
      return k.toString;
    }
    return "";
  }

  string apiVersion() const @trusted {
    if (auto v = "apiVersion" in data.object) {
      return v.toString;
    }
    return "v1";
  }

  Json metadata() const @trusted {
    if (auto m = "metadata" in data.object) {
      return *m;
    }
    return Json.emptyObject;
  }

  Json spec() const @trusted {
    if (auto s = "spec" in data.object) {
      return *s;
    }
    return Json.emptyObject;
  }

  Json status() const @trusted {
    if (auto st = "status" in data.object) {
      return *st;
    }
    return Json.emptyObject;
  }
}