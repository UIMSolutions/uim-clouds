module uim.sap.btp.client;

import std.json : Json, parseJSON;
import std.string : format;
import vibe.http.client : requestHTTP, HTTPClientResponse;
import vibe.http.common : HTTPMethod;
import vibe.stream.operations : readAllUTF8;

import uim.sap.btp.config;
import uim.sap.btp.helpers;

class SAPBTPClient {
  private SAPBTPConfig cfg;

  this(SAPBTPConfig cfg) {
    this.cfg = cfg;
  }

  @property SAPBTPConfig config() {
    return cfg;
  }

  Json get(string path, string[string] query = null, string service = "") {
    return request(HTTPMethod.GET, path, query, "", service);
  }

  Json post(string path, string[string] query, string body, string service = "") {
    return request(HTTPMethod.POST, path, query, body, service);
  }

  Json getApplications() {
    return get("/v2/apps", null, "cf");
  }

  Json getSpaces() {
    return get("/v2/spaces", null, "cf");
  }

  Json getOrganizations() {
    return get("/v2/organizations", null, "cf");
  }

  Json getBoundServices() {
    return get("/v2/service_bindings", null, "cf");
  }

  private Json request(
    HTTPMethod method,
    string path,
    string[string] query,
    string body,
    string service = ""
  ) {
    auto baseUrl = getBaseUrl(cfg);
    auto servicePath = createServicePath(service, normalizePath(path));
    auto queryString = buildQuery(query);
    auto url = baseUrl ~ servicePath ~ queryString;

    HTTPClientResponse response = requestHTTP(url, (scope req) {
      req.method = method;
      
      // Set authentication
      if (cfg.useOAuth2 && cfg.accessToken.length > 0) {
        req.headers["Authorization"] = getBearerToken(cfg.accessToken);
      } else if (cfg.username.length > 0 && cfg.password.length > 0) {
        req.headers["Authorization"] = encodeBasicAuth(cfg.username, cfg.password);
      }
      
      req.headers["Content-Type"] = "application/json";
      req.headers["Accept"] = "application/json";

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
