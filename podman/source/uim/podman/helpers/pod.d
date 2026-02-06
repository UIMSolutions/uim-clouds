module uim.podman.helpers.pod;

import uim.podman;
@safe:

/// Creates a pod config for a simple pod creation.
Json createPodConfig(string name, string[] portBindings = []) {
  Json[] ports;
  foreach (port; portBindings) {
    ports ~= Json(port);
  }

  Json config = Json([
    "Name": Json(name),
    "Share": Json(["pid", "ipc", "uts"])
  ]);
  
  if (ports.length > 0) {
    config["PortMappings"] = Json(ports);
  }
  
  return config;
}
