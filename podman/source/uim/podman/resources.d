/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.resources;

import std.json : JSONValue;

@safe:

/// Represents a Podman container.
struct Container {
  string id;
  string name;
  string image;
  string state;
  string status;
  long created;
  long started;
  long finished;
  string[] ports;
  string[string] labels;
  string exitCode;

  this(JSONValue data) {
    if (auto id = "Id" in data.object) id_data = id.str;
    if (auto names = "Names" in data.object && names.type == JSONValue.Type.array && names.array.length > 0) {
      name = names.array[0].str;
    }
    if (auto image = "Image" in data.object) {
      this.image = image.str;
    }
    if (auto state = "State" in data.object) {
      this.state = state.str;
    }
    if (auto status = "Status" in data.object) {
      this.status = status.str;
    }
    if (auto created = "Created" in data.object) {
      this.created = created.integer;
    }
    if (auto labels = "Labels" in data.object && labels.type == JSONValue.Type.object) {
      foreach (key, value; labels.object) {
        this.labels[key] = value.str;
      }
    }
  }
}

/// Represents a Podman image.
struct Image {
  string id;
  string[] repoTags;
  long created;
  long size;
  string virtualSize;
  string[string] labels;

  this(JSONValue data) {
    if (auto id = "Id" in data.object) {
      this.id = id.str;
    }
    if (auto repoTags = "RepoTags" in data.object && repoTags.type == JSONValue.Type.array) {
      foreach (tag; repoTags.array) {
        this.repoTags ~= tag.str;
      }
    }
    if (auto created = "Created" in data.object) {
      this.created = created.integer;
    }
    if (auto size = "Size" in data.object) {
      this.size = size.integer;
    }
    if (auto labels = "Labels" in data.object && labels.type == JSONValue.Type.object) {
      foreach (key, value; labels.object) {
        this.labels[key] = value.str;
      }
    }
  }
}

/// Represents a Podman pod.
struct Pod {
  string id;
  string name;
  string status;
  long created;
  long started;
  int numContainers;
  string[] containerIds;
  string[string] labels;

  this(JSONValue data) {
    if (auto id = "Id" in data.object) {
      this.id = id.str;
    }
    if (auto name = "Name" in data.object) {
      this.name = name.str;
    }
    if (auto status = "Status" in data.object) {
      this.status = status.str;
    }
    if (auto created = "Created" in data.object) {
      this.created = created.integer;
    }
    if (auto containers = "Containers" in data.object && containers.type == JSONValue.Type.array) {
      this.numContainers = cast(int)containers.array.length;
    }
    if (auto labels = "Labels" in data.object && labels.type == JSONValue.Type.object) {
      foreach (key, value; labels.object) {
        this.labels[key] = value.str;
      }
    }
  }
}

/// Represents a Podman volume.
struct Volume {
  string name;
  string driver;
  string mountPoint;
  string[] labels;
  JSONValue options;

  this(JSONValue data) {
    if (auto name = "Name" in data.object) {
      this.name = name.str;
    }
    if (auto driver = "Driver" in data.object) {
      this.driver = driver.str;
    }
    if (auto mountPoint = "Mountpoint" in data.object) {
      this.mountPoint = mountPoint.str;
    }
    if (auto options = "Options" in data.object) {
      this.options = options;
    }
  }
}

/// Represents a Podman network.
struct Network {
  string id;
  string name;
  string driver;
  string scope;
  string ipam;

  this(JSONValue data) {
    if (auto id = "Id" in data.object) {
      this.id = id.str;
    }
    if (auto name = "Name" in data.object) {
      this.name = name.str;
    }
    if (auto driver = "Driver" in data.object) {
      this.driver = driver.str;
    }
    if (auto scope = "Scope" in data.object) {
      this.scope = scope.str;
    }
  }
}

/// Represents container logs response.
struct LogsResponse {
  string output;
  bool isError;

  this(string output, bool isError = false) {
    this.output = output;
    this.isError = isError;
  }
}
