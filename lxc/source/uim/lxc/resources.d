/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.lxc.resources;

import std.json : Json;

@safe:

/// Represents an LXC container.
struct Container {
  string name;
  string status;
  bool ephemeral;
  long created;
  long lastUsed;
  string[] devices;
  string[string] config;
  Json expandedConfig;

  this(Json data) {
    if (auto name = "name" in data.object) {
      this.name = name.toString;
    }
    if (auto status = "status" in data.object) {
      this.status = status.toString;
    }
    if (auto ephemeral = "ephemeral" in data.object) {
      this.ephemeral = ephemeral.type == Json.Type.true_;
    }
    if (auto created = "created" in data.object) {
      this.created = created.integer;
    }
    if (auto lastUsed = "last_used_at" in data.object) {
      this.lastUsed = lastUsed.integer;
    }
    if (auto config = "config" in data.object && config.type == Json.Type.object) {
      foreach (key, value; config.object) {
        this.config[key] = value.toString;
      }
    }
  }
}

/// Represents container state information.
struct ContainerState {
  string name;
  string status;
  long timestamp;
  string pid;
  bool autostart;
  int cpuUsage;
  long memoryUsage;
  long memoryLimit;
  string[string] processes;

  this(Json data) {
    if (auto name = "name" in data.object) {
      this.name = name.toString;
    }
    if (auto status = "status" in data.object) {
      this.status = status.toString;
    }
    if (auto timestamp = "timestamp" in data.object) {
      this.timestamp = timestamp.integer;
    }
    if (auto autostart = "config" in data.object) {
      if (auto as = "boot.autostart" in autostart.object) {
        this.autostart = as.toString == "1" || as.toString == "true";
      }
    }
  }
}

/// Represents an LXC image or template.
struct Image {
  string name;
  string description;
  string properties;
  long size;
  string type;
  Json metadata;

  this(Json data) {
    if (auto name = "name" in data.object) {
      this.name = name.toString;
    }
    if (auto description = "description" in data.object) {
      this.description = description.toString;
    }
    if (auto size = "size" in data.object) {
      this.size = size.integer;
    }
    if (auto type = "type" in data.object) {
      this.type = type.toString;
    }
  }
}

/// Represents an LXC network.
struct Network {
  string name;
  string type;
  string[] members;
  string[string] config;
  Json expandedConfig;

  this(Json data) {
    if (auto name = "name" in data.object) {
      this.name = name.toString;
    }
    if (auto type = "type" in data.object) {
      this.type = type.toString;
    }
    if (auto members = "members" in data.object && members.isArray) {
      foreach (member; members.array) {
        this.members ~= member.toString;
      }
    }
    if (auto config = "config" in data.object && config.type == Json.Type.object) {
      foreach (key, value; config.object) {
        this.config[key] = value.toString;
      }
    }
  }
}

/// Represents an LXC storage pool.
struct StoragePool {
  string name;
  string driver;
  string source;
  long usage;
  long totalSpace;
  string[string] config;

  this(Json data) {
    if (auto name = "name" in data.object) {
      this.name = name.toString;
    }
    if (auto driver = "driver" in data.object) {
      this.driver = driver.toString;
    }
    if (auto source = "source" in data.object) {
      this.source = source.toString;
    }
    if (auto config = "config" in data.object && config.type == Json.Type.object) {
      foreach (key, value; config.object) {
        this.config[key] = value.toString;
      }
    }
  }
}

/// Represents an LXC storage volume.
struct StorageVolume {
  string name;
  string poolName;
  string volumeType;
  long size;
  string[string] config;

  this(Json data) {
    if (auto name = "name" in data.object) {
      this.name = name.toString;
    }
    if (auto volumeType = "type" in data.object) {
      this.volumeType = volumeType.toString;
    }
    if (auto config = "config" in data.object && config.type == Json.Type.object) {
      foreach (key, value; config.object) {
        this.config[key] = value.toString;
      }
    }
  }
}

/// Represents a container snapshot.
struct Snapshot {
  string name;
  string containerName;
  long createdAt;
  string description;
  bool isStateful;
  Json config;

  this(Json data) {
    if (auto name = "name" in data.object) {
      this.name = name.toString;
    }
    if (auto createdAt = "created_at" in data.object) {
      this.createdAt = createdAt.integer;
    }
    if (auto description = "description" in data.object) {
      this.description = description.toString;
    }
  }
}

/// Represents an LXC device.
struct Device {
  string name;
  string type;
  string[string] properties;

  this(string name, string type) {
    this.name = name;
    this.type = type;
  }
}

/// Represents operation status.
struct Operation {
  string id;
  string operationType;
  string description;
  string status;
  string statusCode;
  long createdAt;
  long updatedAt;
  bool mayCancel;
  Json metadata;

  this(Json data) {
    if (auto id = "id" in data.object) {
      this.id = id.toString;
    }
    if (auto type = "type" in data.object) {
      this.operationType = type.toString;
    }
    if (auto description = "description" in data.object) {
      this.description = description.toString;
    }
    if (auto status = "status" in data.object) {
      this.status = status.toString;
    }
    if (auto createdAt = "created_at" in data.object) {
      this.createdAt = createdAt.integer;
    }
    if (auto updatedAt = "updated_at" in data.object) {
      this.updatedAt = updatedAt.integer;
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
