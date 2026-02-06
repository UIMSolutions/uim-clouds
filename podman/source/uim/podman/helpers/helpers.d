/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.podman.helpers.helpers;

import uim.podman;

@safe:

/// Converts string array to Json array.
Json stringArrayToJSON(string[] array) {
  Json[] result;
  foreach (item; array) {
    result ~= Json(item);
  }
  return Json(result);
}

/// Converts string map to Json object.
Json stringMapToJSON(string[string] map) {
  Json[string] result;
  foreach (key, value; map) {
    result[key] = Json(value);
  }
  return Json(result);
}

/// Creates a config for local Unix socket connection (default).
PodmanConfig defaultConfig() @safe {
  return PodmanConfig("unix:///run/podman/podman.sock", "v4.0.0", false, "", true);
}

/// Creates a config for system-wide Unix socket connection.
PodmanConfig systemConfig() @safe {
  return PodmanConfig("unix:///run/podman/podman.sock", "v4.0.0", false, "", false);
}

/// Creates a config for TCP connection.
PodmanConfig tcpConfig(string host = "127.0.0.1", ushort port = 8080) @safe {
  return PodmanConfig("http://" ~ host ~ ":" ~ to!string(port), "v4.0.0", false, "", false);
}

/// Creates a config for secure TCP connection.
PodmanConfig secureTcpConfig(string host, ushort port = 8081, string caCertPath = "") @safe {
  return PodmanConfig("https://" ~ host ~ ":" ~ to!string(port), "v4.0.0", false, caCertPath, false);
}

/// Checks if endpoint is a Unix socket.
bool isUnixSocket(string endpoint) @safe {
  return endpoint.startsWith("unix://");
}

/// Extracts socket path from Unix endpoint.
string getUnixSocketPath(string endpoint) @safe {
  return isUnixSocket(endpoint) ? endpoint[7 .. $] : "";  // Strip "unix://"
}

/// Checks if endpoint is TCP.
bool isTcpEndpoint(string endpoint) @safe {
  return endpoint.startsWith("http://") || endpoint.startsWith("https://");
}

/// Extracts TCP URL from endpoint.
string getTcpUrl(string endpoint) @safe {
  return isTcpEndpoint(endpoint) ? endpoint : "";
}

/// Gets the user socket path.
string getUserSocketPath() @safe {
  return "unix:///run/user/1000/podman/podman.sock";
}

/// Gets the system socket path.
string getSystemSocketPath() @safe {
  return "unix:///run/podman/podman.sock";
}



