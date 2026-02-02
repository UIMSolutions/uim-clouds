/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.docker.resources;

import uim.docker;

// Container resource wrapper
struct Container {
  Json data;

  string id() const @trusted {
    if (auto i = "Id" in data.object) {
      return i.toString;
    }
    return "";
  }

  string name() const @trusted {
    if (auto names = "Names" in data.object) {
      if (names.isArray && names.array.length > 0) {
        auto nameStr = names.array[0].toString;
        return nameStr.length > 0 && nameStr[0] == '/' ? nameStr[1 .. $] : nameStr;
      }
    }
    return "";
  }

  string status() const @trusted {
    if (auto s = "State" in data.object) {
      return s.toString;
    }
    return "unknown";
  }

  string image() const @trusted {
    if (auto img = "Image" in data.object) {
      return img.toString;
    }
    return "";
  }

  Json[] ports() const @trusted {
    if (auto p = "Ports" in data.object) {
      if (p.isArray) {
        return p.array;
      }
    }
    return [];
  }

  string[] labels() const @trusted {
    if (auto l = "Labels" in data.object) {
      if (l.type == Json.Type.object) {
        return l.object.keys;
      }
    }
    return [];
  }
}

// Image resource wrapper
struct Image {
  Json data;

  string id() const @trusted {
    if (auto i = "Id" in data.object) {
      return i.toString;
    }
    return "";
  }

  string[] repoTags() const @trusted {
    if (auto tags = "RepoTags" in data.object) {
      if (tags.isArray) {
        return tags.toArray.map!(tag => tag.toString);
      }
    }
    return null;
  }

  long size() const @trusted {
    if (auto s = "Size" in data.object) {
      if (s.type == Json.Type.integer) {
        return s.integer;
      }
    }
    return 0;
  }

  long created() const @trusted {
    if (auto c = "Created" in data.object) {
      if (c.type == Json.Type.integer) {
        return c.integer;
      }
    }
    return 0;
  }
}

// Volume resource wrapper
struct Volume {
  Json data;

  string name() const @trusted {
    if (auto n = "Name" in data.object) {
      return n.toString;
    }
    return "";
  }

  string driver() const @trusted {
    if (auto d = "Driver" in data.object) {
      return d.toString;
    }
    return "";
  }

  Json mountpoint() const @trusted {
    if (auto m = "Mountpoint" in data.object) {
      return *m;
    }
    return Json("");
  }

  Json labels() const @trusted {
    if (auto l = "Labels" in data.object) {
      return *l;
    }
    return Json.object;
  }
}

// Network resource wrapper
struct Network {
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
    return Json.object;
  }
}
