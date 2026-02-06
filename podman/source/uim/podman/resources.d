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
    if (data.hasKey("Id")) id = data["Id"].toString;
    if (data.hasKey("Names") && data["Names"].isArray && data["Names"].array.length > 0) {
      name = data["Names"].array[0].toString;
    }
    if (data.hasKey("Image")) {
      this.image = data["Image"].toString;
    }
    if (data.hasKey("State")) {
      this.state = data["State"].toString;
    }
    if (data.hasKey("Status")) {
      this.status = data["Status"].toString;
    }
    if (data.hasKey("Created")) {
      this.created = data["Created"].integer;
    }
    if (data.hasKey("Labels") && data["Labels"].type == Json.Type.object) {
      foreach (key, value; data["Labels"].object) {
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
    if (data.hasKey("Id")) {
      this.id = data["Id"].toString;
    }
    if (data.hasKey("RepoTags") && data["RepoTags"].isArray) {
      foreach (tag; data["RepoTags"].array) {
        this.repoTags ~= tag.toString;
      }
    }
    if (data.hasKey("Created")) {
      this.created = data["Created"].integer;
    }
    if (data.hasKey("Size")) {
      this.size = data["Size"].integer;
    }
    if (data.hasKey("Labels") && data["Labels"].type == Json.Type.object) {
      foreach (key, value; data["Labels"].object) {
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
    if (data.hasKey("Id")) {
      this.id = data["Id"].toString;
    }
    if (data.hasKey("Name")) {
      this.name = data["Name"].toString;
    }
    if (data.hasKey("Status")) {
      this.status = data["Status"].toString;
    }
    if (data.hasKey("Created")) {
      this.created = data["Created"].integer;
    }
    if (data.hasKey("Containers") && data["Containers"].isArray) {
      this.numContainers = cast(int)data["Containers"].array.length;
    }
    if (data.hasKey("Labels") && data["Labels"].type == Json.Type.object) {
      foreach (key, value; data["Labels"].object) {
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
  string[string] labels;
  Json options;

  this(Json data) {
    if (data.hasKey("Name")) {
      this.name = data["Name"].toString;
    }
    if (data.hasKey("Driver")) {
      this.driver = data["Driver"].toString;
    }
    if (data.hasKey("Mountpoint")) {
      this.mountPoint = data["Mountpoint"].toString;
    }
    if (data.hasKey("Options")) {
      this.options = data["Options"];
    }
  }
}

/// Represents a Podman network.
struct Network {
  string id;
  string name;
  string driver;
  string scope_;
  string ipam;

  this(Json data) {
    if (data.hasKey("Id")) {
      this.id = data["Id"].toString;
    }
    if (data.hasKey("Name")) {
      this.name = data["Name"].toString;
    }
    if (data.hasKey("Driver")) {
      this.driver = data["Driver"].toString;
    }
    if (data.hasKey("Scope")) {
      this.scope_ = data["Scope"].toString;
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
