/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.lxc.config;

import std.conv : to;
import std.exception : enforce;
import std.string : startsWith;

// LXC daemon connection configuration
struct LXCConfig {
  string endpoint;  // e.g., "unix:///var/lib/lxc/lxc.socket" or "http://127.0.0.1:8443"
  string apiVersion = "v1.0";
  bool insecureSkipVerify = false;
  string caCertPath = "";
  string certificatePath = "";
  string keyPath = "";
  bool useUnixSocket = true;
}

/// Creates a config for local Unix socket connection (default).
LXCConfig defaultConfig() @safe {
  return LXCConfig(
    "unix:///var/lib/lxc/lxc.socket",
    "v1.0",
    false,
    "",
    "",
    "",
    true
  );
}

/// Creates a config for HTTP connection.
LXCConfig httpConfig(string host = "127.0.0.1", ushort port = 8080) @safe {
  return LXCConfig(
    "http://" ~ host ~ ":" ~ to!string(port),
    "v1.0",
    false,
    "",
    "",
    "",
    false
  );
}

/// Creates a config for HTTPS connection with client certificates.
LXCConfig httpsConfig(
  string host,
  ushort port = 8443,
  string caCertPath = "",
  string certificatePath = "",
  string keyPath = ""
) @safe {
  return LXCConfig(
    "https://" ~ host ~ ":" ~ to!string(port),
    "v1.0",
    false,
    caCertPath,
    certificatePath,
    keyPath,
    false
  );
}

/// Checks if endpoint is a Unix socket.
bool isUnixSocket(string endpoint) @safe {
  return endpoint.startsWith("unix://");
}

/// Extracts socket path from Unix endpoint.
string getUnixSocketPath(string endpoint) @safe {
  if (isUnixSocket(endpoint)) {
    return endpoint[7 .. $];  // Strip "unix://"
  }
  return "";
}

/// Checks if endpoint is HTTP or HTTPS.
bool isHttpEndpoint(string endpoint) @safe {
  return endpoint.startsWith("http://") || endpoint.startsWith("https://");
}

/// Checks if endpoint is HTTPS.
bool isHttpsEndpoint(string endpoint) @safe {
  return endpoint.startsWith("https://");
}

/// Extracts HTTP URL from endpoint.
string getHttpUrl(string endpoint) @safe {
  if (isHttpEndpoint(endpoint)) {
    return endpoint;
  }
  return "";
}
