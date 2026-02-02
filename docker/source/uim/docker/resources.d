/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.docker.resources;

import uim.docker;
@safe:

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
    return Json.emptyObject;
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
    return Json.emptyObject;
  }
}
