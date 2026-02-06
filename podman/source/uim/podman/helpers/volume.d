module uim.podman.helpers.volume;

import uim.podman;

@safe:

/// Creates volume mounts for container.
Json createVolumeMounts(string[string] mounts) {
  Json[] volumeList;
  foreach (containerPath, hostPath; mounts) {
    volumeList ~= createVolumeMount(containerPath, hostPath);
  }
  return Json(volumeList);
}

// Creates a single volume mount configuration.
Json createVolumeMount(string containerPath, string hostPath) {
  return [
      "Source": Json(hostPath),
      "Target": Json(containerPath),
      "Type": Json("bind")
    ].toJson;
}
