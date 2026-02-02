/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.docker.resources;

import uim.docker;

// Image resource wrapper
struct DockerImage {
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
        string[] result;
        foreach (tag; tags.array) {
          result ~= tag.toString;
        }
        return result;
      }
    }
    return [];
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

// Volume resource wrapper
struct DockerVolume {
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

