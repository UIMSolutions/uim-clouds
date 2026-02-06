module uim.azure.client;

import std.json : Json, parseJSON;
import std.string : format;
import vibe.http.client : requestHTTP, HTTPClientResponse, HTTPClientSettings;
import vibe.http.common : HTTPMethod;
import vibe.stream.operations : readAllUTF8;

import uim.azure.config;
import uim.azure.helpers;

class AzureClient {
  private AzureConfig cfg;

  this(AzureConfig cfg) {
    this.cfg = cfg;
  }

  @property AzureConfig config() {
    return cfg;
  }

  Json get(string path, string[string] query = null) {
    return requestJson(HTTPMethod.GET, path, query, Json(null));
  }

  Json post(string path, string[string] query, Json body) {
    return requestJson(HTTPMethod.POST, path, query, body);
  }

  private Json requestJson(HTTPMethod method, string path, string[string] query, Json body) {
    auto settings = new HTTPClientSettings;
    auto url = joinUrl(cfg.baseUrl, normalizePath(path)) ~ buildQuery(query);

    HTTPClientResponse response = requestHTTP(url, settings, (scope req) {
      req.method = method;
      req.headers["Authorization"] = "Bearer " ~ cfg.accessToken;
      req.headers["Content-Type"] = "application/json";

      if (body.type != Json.Type.null_) {
        auto payload = body.toString();
        req.writeBody(payload);
      }
    });

    auto content = response.bodyReader.readAllUTF8();
    if (content.length == 0) {
      return Json(null);
    }
    return parseJSON(content);
  }
}
