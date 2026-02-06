module uim.gcp.helpers;

import std.array : appender;
import std.uri : encodeComponent;
import std.digest.sha : sha256Of;
import std.base64 : Base64;
import std.conv : toHexString;
import std.datetime.systime : Clock;
import std.format : format;
import std.json : Json, parseJSON;

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

ulong getCurrentTimestamp() {
  auto now = Clock.currTime();
  return now.toUnixTime();
}

string base64Encode(ubyte[] data) {
  return Base64.encode(data);
}

string base64Decode(string data) {
  return cast(string) Base64.decode(data);
}

string createJWTHeader() {
  return base64Encode(cast(ubyte[])`{"alg":"RS256","typ":"JWT"}`);
}

string createJWTClaim(string clientEmail, string projectId, string scope) {
  auto now = getCurrentTimestamp();
  auto exp = now + 3600; // 1 hour expiration
  
  auto claimJson = format(
    `{"iss":"%s","scope":"%s","aud":"https://oauth2.googleapis.com/token","exp":%d,"iat":%d}`,
    clientEmail,
    scope,
    exp,
    now
  );
  
  return base64Encode(cast(ubyte[]) claimJson);
}

string createSignatureInput(string header, string claim) {
  return header ~ "." ~ claim;
}
