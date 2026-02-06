module uim.gcp.client;

import std.json : Json, parseJSON;
import std.string : format;
import vibe.http.client : requestHTTP, HTTPClientResponse;
import vibe.http.common : HTTPMethod;
import vibe.stream.operations : readAllUTF8;

import uim.gcp.config;
import uim.gcp.helpers;

class GCPClient {
  private GCPConfig cfg;

  this(GCPConfig cfg) {
    this.cfg = cfg;
  }

  @property GCPConfig config() {
    return cfg;
  }

  Json get(string path, string[string] query = null) {
    return request(HTTPMethod.GET, path, query, "");
  }

  Json post(string path, string[string] query, string body) {
    return request(HTTPMethod.POST, path, query, body);
  }

  Json computeListInstances(string zone) {
    auto path = format("compute/v1/projects/%s/zones/%s/instances", cfg.projectId, zone);
    return get(path);
  }

  Json storageListBuckets() {
    auto path = format("storage/v1/b?project=%s", cfg.projectId);
    return get(path);
  }

  Json cloudrunListServices(string region = "us-central1") {
    auto path = format("v1/projects/%s/locations/%s/services", cfg.projectId, region);
    return get(path);
  }

  private Json request(HTTPMethod method, string path, string[string] query, string body) {
    auto baseUrl = "https://www.googleapis.com";
    auto uri = normalizePath(path);
    auto queryString = buildQuery(query);
    auto url = baseUrl ~ uri ~ queryString;

    HTTPClientResponse response = requestHTTP(url, (scope req) {
      req.method = method;
      req.headers["Authorization"] = "Bearer " ~ cfg.accessToken;
      req.headers["Content-Type"] = "application/json";

      if (body.length > 0) {
        req.writeBody(body);
      }
    });

    auto content = response.bodyReader.readAllUTF8();
    if (content.length == 0) {
      return Json(null);
    }

    // Try to parse as JSON, fall back to null if not JSON
    try {
      return parseJSON(content);
    } catch {
      return Json(null);
    }
  }
}
