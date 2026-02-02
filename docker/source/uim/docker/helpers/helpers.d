/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.docker.helpers.helpers;

import uim.docker;

@safe:

/// Creates a container config for a simple image run.
Json createContainerConfig(string image, string[] cmd = [], string[] env = []) {
  Json[] cmdArray = cmd.map!(c => Json(c)).array;
  Json[] envArray = env.map!(e => Json(e)).array;

  Json config = Json([
    "Image": Json(image),
    "Cmd": Json(cmdArray),
    "Env": Json(envArray)
  ]);
  return config;
}

/// Creates port bindings for container.
Json createPortBindings(string[string] portMap) {
  Json[string] bindings;
  foreach (containerPort, hostPort; portMap) {
    bindings[containerPort] = Json([
      Json([
        "HostPort": Json(hostPort)
      ])
    ]);
  }
  return Json(bindings);
}

/// Creates volume mounts for container.
Json createVolumeMounts(string[string] mounts) {
  Json[] volumeList;
  foreach (containerPath, hostPath; mounts) {
    volumeList ~= Json([
      "Source": Json(hostPath),
      "Target": Json(containerPath),
      "ReadOnly": Json(false)
    ]);
  }
  return Json(volumeList);
}

/// Creates environment variables from map.
string[] createEnvArray(string[string] env) {
  return env.byKeyValue.map!(kv => kv.key ~ "=" ~ kv.value).array;
}

/// Creates a volume creation config.
Json createVolumeConfig(string name, string driver = "local") {
  return [
    "Name": Json(name),
    "Driver": Json(driver)
  ].toJson;
}

/// Creates a network creation config.
Json createNetworkConfig(string name, string driver = "bridge") {
  return [
    "Name": Json(name),
    "Driver": Json(driver)
  ].toJson;
}

/// Parses image reference into components.
struct ImageRef {
  string registry;
  string repository;
  string tag;

  string toString() const {
    string result;
    if (registry.length > 0) {
      result ~= registry ~ "/";
    }
    result ~= repository;
    if (tag.length > 0) {
      result ~= ":" ~ tag;
    }
    return result;
  }
}

/// Parses an image reference string.
ImageRef parseImageRef(string imageRef) @safe {
  ImageRef result;
  result.tag = "latest";

  size_t tagIdx = imageRef.length;
  size_t colonIdx = imageRef.length - 1;
  for (ptrdiff_t i = cast(ptrdiff_t)imageRef.length - 1; i >= 0; --i) {
    if (imageRef[i] == ':') {
      colonIdx = i;
      break;
    }
    if (imageRef[i] == '/') {
      colonIdx = imageRef.length;
      break;
    }
  }

  if (colonIdx < imageRef.length && imageRef[colonIdx] == ':') {
    result.tag = imageRef[colonIdx + 1 .. $];
    imageRef = imageRef[0 .. colonIdx];
  }

  size_t slashIdx = imageRef.length;
  for (ptrdiff_t i = cast(ptrdiff_t)imageRef.length - 1; i >= 0; --i) {
    if (imageRef[i] == '/') {
      slashIdx = i;
      break;
    }
  }

  if (slashIdx > 0 && imageRef[0 .. slashIdx].indexOf('/') != -1) {
    result.registry = imageRef[0 .. slashIdx];
    result.repository = imageRef[slashIdx + 1 .. $];
  } else if (slashIdx < imageRef.length) {
    result.registry = imageRef[0 .. slashIdx];
    result.repository = imageRef[slashIdx + 1 .. $];
  } else {
    result.repository = imageRef;
  }

  return result;
}

private size_t indexOf(string str, char c) @safe {
  for (size_t i = 0; i < str.length; ++i) {
    if (str[i] == c) {
      return i;
    }
  }
  return str.length;
}
