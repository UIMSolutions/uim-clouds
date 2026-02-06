module uim.podman.helpers.container;

import uim.podman;
@safe:

/// Creates a container config for a simple image run.
Json createContainerConfig(string image, string[] cmd = [], string[] env = []) {
  Json[] cmdArray;
  foreach (c; cmd) {
    cmdArray ~= Json(c);
  }

  Json[] envArray;
  foreach (e; env) {
    envArray ~= Json(e);
  }

  Json config = Json([
    "Image": Json(image),
    "Cmd": Json(cmdArray),
    "Env": Json(envArray)
  ]);
  return config;
}