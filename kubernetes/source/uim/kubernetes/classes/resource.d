module uim.kubernetes.classes.resource;

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