module uim.azure.helpers;

import std.array : appender;
import std.uri : encodeComponent;

string normalizePath(string path) {
  if (path.length == 0) {
    return "/";
  }
  return path[0] == '/' ? path : "/" ~ path;
}

string joinUrl(string baseUrl, string path) {
  if (baseUrl.length == 0) {
    return path;
  }

  if (baseUrl[$ - 1] == '/' && path.length > 0 && path[0] == '/') {
    return baseUrl[0 .. $ - 1] ~ path;
  }

  if (baseUrl[$ - 1] != '/' && (path.length == 0 || path[0] != '/')) {
    return baseUrl ~ "/" ~ path;
  }

  return baseUrl ~ path;
}

string buildQuery(string[string] query) {
  if (query is null || query.length == 0) {
    return "";
  }

  auto result = appender!string();
  bool first = true;
  foreach (key, value; query) {
    if (first) {
      result.put('?');
      first = false;
    } else {
      result.put('&');
    }
    result.put(encodeComponent(key));
    result.put('=');
    result.put(encodeComponent(value));
  }
  return result.data;
}
