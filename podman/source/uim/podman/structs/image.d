module uim.podman.structs.image;

import uim.podman;

@safe:

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
      this.id = data["Id"].getString;
    }
    if (data.hasKey("RepoTags") && data["RepoTags"].isArray) {
      this.repoTags ~= data["RepoTags"].toArray.map!(tag => tag.getString).array;
    }
    if (data.hasKey("Created")) {
      this.created = data["Created"].integer;
    }
    if (data.hasKey("Size")) {
      this.size = data["Size"].integer;
    }
    if (data.hasKey("Labels") && data["Labels"].isObject) {
      foreach (key, value; data["Labels"].toMap) {
        this.labels[key] = value.getString;
      }
    }
  }
}
