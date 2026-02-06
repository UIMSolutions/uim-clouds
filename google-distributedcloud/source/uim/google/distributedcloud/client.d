module uim.google.distributedcloud.client;

import std.json : Json, parseJSON;
import std.string : format;
import vibe.http.client : requestHTTP, HTTPClientResponse;
import vibe.http.common : HTTPMethod;
import vibe.stream.operations : readAllUTF8;

import uim.google.distributedcloud.config;
import uim.google.distributedcloud.helpers;

class GDCClient {
  private GDCConfig cfg;

  this(GDCConfig cfg) {
    this.cfg = cfg;
  }

  @property GDCConfig config() {
    return cfg;
  }

  Json get(string path, string[string] query = null) {
    return request(HTTPMethod.GET, path, query, "");
  }

  Json post(string path, string[string] query, string body) {
    return request(HTTPMethod.POST, path, query, body);
  }

  Json listClusters(string location = "") {
    auto loc = location.length > 0 ? location : cfg.region;
    auto path = format("v1/projects/%s/locations/%s/clusters", cfg.projectId, loc);
    return get(path);
  }

  Json listNodes(string location = "") {
    auto loc = location.length > 0 ? location : cfg.region;
    auto path = format("v1/projects/%s/locations/%s/nodes", cfg.projectId, loc);
    return get(path);
  }

  Json listMachineLearningModels(string location = "") {
    auto loc = location.length > 0 ? location : cfg.region;
    auto path = format("v1/projects/%s/locations/%s/models", cfg.projectId, loc);
    return get(path);
  }

  private Json request(HTTPMethod method, string path, string[string] query, string body) {
    auto baseUrl = "https://googleapis.com";
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
