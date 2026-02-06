module uim.aws.client;

import std.json : Json, parseJSON;
import std.string : format;
import vibe.http.client : requestHTTP, HTTPClientResponse;
import vibe.http.common : HTTPMethod;
import vibe.stream.operations : readAllUTF8;

import uim.aws.config;
import uim.aws.helpers;

class AWSClient {
  private AWSConfig cfg;

  this(AWSConfig cfg) {
    this.cfg = cfg;
  }

  @property AWSConfig config() {
    return cfg;
  }

  Json get(string path, string[string] query = null) {
    return request(HTTPMethod.GET, path, query, "");
  }

  Json post(string path, string[string] query, string body) {
    return request(HTTPMethod.POST, path, query, body);
  }

  Json ec2DescribeInstances() {
    auto query = ["Action": "DescribeInstances", "Version": "2016-11-15"];
    return get("", query);
  }

  private Json request(HTTPMethod method, string path, string[string] query, string body) {
    auto host = format("%s.amazonaws.com", cfg.service);
    auto baseUrl = format("https://%s", host);
    auto uri = normalizePath(path);
    auto queryString = buildQuery(query);
    
    auto authHeader = signAWS(
      method == HTTPMethod.GET ? "GET" : "POST",
      host,
      uri,
      queryString.length > 0 ? queryString[1..$] : "",
      body.length > 0 ? body : "",
      cfg.accessKeyId,
      cfg.secretAccessKey,
      cfg.region,
      cfg.service
    );

    auto url = baseUrl ~ uri ~ queryString;

    HTTPClientResponse response = requestHTTP(url, (scope req) {
      req.method = method;
      req.headers["Authorization"] = authHeader;
      req.headers["X-Amz-Date"] = getAWSDatetime();
      req.headers["X-Amz-Content-Sha256"] = sha256Hash(body);

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
