/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.docker.classes.image;

import uim.docker;
@safe:

// Image resource wrapper
class DockerImage {
this() {
    _data = Json.emptyObject;
}

this(Json data) {
    this.data = data;
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
      if (s.isInteger) {
        return s.integer;
      }
    }
    return 0;
  }

  long created() const @trusted {
    if (auto c = "Created" in data.object) {
      if (c.isInteger) {
        return c.integer;
      }
    }
    return 0;
  }
}