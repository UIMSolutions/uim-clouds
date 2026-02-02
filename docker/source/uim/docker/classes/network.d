module uim.docker.classes.network;

import uim.docker;
@safe:

// Network resource wrapper
class DockerNetwork {
    this() {
        data = Json.emptyObject;
    }

  Json data;

  string name() const @trusted {
    if (auto n = "Name" in data.object) {
      return n.toString;
    }
    return "";
  }

  string id() const @trusted {
    if (auto i = "Id" in data.object) {
      return i.toString;
    }
    return "";
  }

  string driver() const @trusted {
    if (auto d = "Driver" in data.object) {
      return d.toString;
    }
    return "";
  }

  Json scopeValue() const @trusted {
    if (auto s = "Scope" in data.object) {
      return *s;
    }
    return Json("local");
  }

  Json containers() const @trusted {
    if (auto c = "Containers" in data.object) {
      return *c;
    }
    return Json.emptyObject;
  }
}
