module uim.podman.helpers.port;

import uim.podman;
@safe:

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