/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.docker.classes.container;

import uim.docker;
@safe:

// Container resource wrapper
class DockerContainer {
    this() {
        data = Json.emptyObject;
    }

    protected Json _data;
    @property Json data() const @trusted {
        return _data;
    }

    @property void data(Json value) @trusted {
        _data = value;
    }

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
    return data.getString("State", "unknown");
  }

  string image() const @trusted {
    return data.getString("Image");
  }

  Json[] ports() const @trusted {
    return data.getArray("Ports").toArray;
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
