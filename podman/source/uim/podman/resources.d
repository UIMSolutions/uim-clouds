/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.resources;

import uim.podman;

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

  this(Json data) {
    if (auto id = "Id" in data.object) id_data = id.toString;
    if (auto names = "Names" in data.object && names.isArray && names.array.length > 0) {
      name = names.array[0].toString;
    }
    if (auto image = "Image" in data.object) {
      this.image = image.toString;
    }
    if (auto state = "State" in data.object) {
      this.state = state.toString;
    }
    if (auto status = "Status" in data.object) {
      this.status = status.toString;
    }
    if (auto created = "Created" in data.object) {
      this.created = created.integer;
    }
    if (auto labels = "Labels" in data.object && labels.type == Json.Type.object) {
      foreach (key, value; labels.object) {
        this.labels[key] = value.toString;
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

  this(Json data) {
    if (auto id = "Id" in data.object) {
      this.id = id.toString;
    }
    if (auto repoTags = "RepoTags" in data.object && repoTags.isArray) {
      foreach (tag; repoTags.array) {
        this.repoTags ~= tag.toString;
      }
    }
    if (auto created = "Created" in data.object) {
      this.created = created.integer;
    }
    if (auto size = "Size" in data.object) {
      this.size = size.integer;
    }
    if (auto labels = "Labels" in data.object && labels.type == Json.Type.object) {
      foreach (key, value; labels.object) {
        this.labels[key] = value.toString;
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

  this(Json data) {
    if (auto id = "Id" in data.object) {
      this.id = id.toString;
    }
    if (auto name = "Name" in data.object) {
      this.name = name.toString;
    }
    if (auto status = "Status" in data.object) {
      this.status = status.toString;
    }
    if (auto created = "Created" in data.object) {
      this.created = created.integer;
    }
    if (auto containers = "Containers" in data.object && containers.isArray) {
      this.numContainers = cast(int)containers.array.length;
    }
    if (auto labels = "Labels" in data.object && labels.type == Json.Type.object) {
      foreach (key, value; labels.object) {
        this.labels[key] = value.toString;
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
  Json options;

  this(Json data) {
    if (auto name = "Name" in data.object) {
      this.name = name.toString;
    }
    if (auto driver = "Driver" in data.object) {
      this.driver = driver.toString;
    }
    if (auto mountPoint = "Mountpoint" in data.object) {
      this.mountPoint = mountPoint.toString;
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

  this(Json data) {
    if (auto id = "Id" in data.object) {
      this.id = id.toString;
    }
    if (auto name = "Name" in data.object) {
      this.name = name.toString;
    }
    if (auto driver = "Driver" in data.object) {
      this.driver = driver.toString;
    }
    if (auto scope = "Scope" in data.object) {
      this.scope = scope.toString;
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
