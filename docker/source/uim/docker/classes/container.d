/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.docker.classes.container;

import uim.docker;

// Container resource wrapper
class DockerContainer {
    this() {
        data = Json.emptyObject;
    }

  Json data;

  string id() const @trusted {
    if (auto i = "Id" in data.object) {
      return i.toString;
    }
    return "";
  }

  string name() const @trusted {
    if (auto names = "Names" in data.object) {
      if (names.isArray && names.toArray.length > 0) {
        auto nameStr = names.array[0].toString;
        return nameStr.length > 0 && nameStr[0] == '/' ?
          nameStr[1 .. $] : nameStr;
      }
    }
    return "";
  }

  string status() const @trusted {
    return data.hasKey("State") ? data["State"].toString : "unknown";
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
