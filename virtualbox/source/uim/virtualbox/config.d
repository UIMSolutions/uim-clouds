/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.virtualbox.config;

import std.conv : to;
import std.string : endsWith;

/// VirtualBox connection configuration
struct VirtualBoxConfig {
  string vboxManagePath = "/usr/bin/VBoxManage";
  string host = "localhost";
  ushort webServicePort = 18083;  // Default vboxwebsrv port
  bool useWebService = false;
  string username = "";
  string password = "";
  int timeoutSeconds = 30;
}

/// Default local config using VBoxManage CLI
VirtualBoxConfig defaultConfig() @safe {
  return VirtualBoxConfig();
}

/// Config using vboxwebsrv
VirtualBoxConfig webServiceConfig(string host = "localhost", ushort port = 18083) @safe {
  VirtualBoxConfig cfg;
  cfg.useWebService = true;
  cfg.host = host;
  cfg.webServicePort = port;
  return cfg;
}

/// Checks if path looks like VBoxManage
bool isVBoxManagePath(string path) @safe {
  return path.endsWith("VBoxManage") || path.endsWith("VBoxManage.exe");
}

/// Builds a web service endpoint
string buildWebServiceEndpoint(string host, ushort port) @safe {
  return "http://" ~ host ~ ":" ~ to!string(port);
}
