module uim.podman.helpers.network;

import uim.podman;

@safe:
/// Creates network settings for container.
Json createNetworkSettings(string networkName, string ipAddress = "", string gateway = "") {
  Json settings = Json([
    "EndpointsConfig": Json([
      networkName: Json([
        "IPAMConfig": Json(Json(null))
      ])
    ])
  ]);
  
  if (ipAddress.length > 0) {
    settings["EndpointsConfig"][networkName]["IPAMConfig"] = Json([
      "IPv4Address": Json(ipAddress)
    ]);
  }
  
  return settings;
}