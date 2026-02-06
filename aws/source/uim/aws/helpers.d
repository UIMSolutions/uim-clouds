module uim.aws.helpers;

import std.array : appender;
import std.uri : encodeComponent;
import std.digest.sha : sha256Of;
import std.digest.hmac : hmac;
import std.base64 : Base64;
import std.conv : hexString, toHexString;
import std.datetime.systime : Clock;
import std.format : format;
import std.ascii : toLower;

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

string getAWSDatetime() {
  auto now = Clock.currTime();
  return format("%04d%02d%02dT%02d%02d%02dZ", now.year, now.month, now.day, now.hour, now.minute, now.second);
}

string getAWSDate() {
  auto now = Clock.currTime();
  return format("%04d%02d%02d", now.year, now.month, now.day);
}

string sha256Hash(string data) {
  auto hash = sha256Of(data);
  return toHexString(hash[]).toLower();
}

string hmacSha256(string key, string message) {
  auto result = hmac!sha256(cast(ubyte[]) key, cast(ubyte[]) message);
  return toHexString(result[]).toLower();
}

string signAWS(
  string method,
  string host,
  string uri,
  string queryString,
  string payload,
  string accessKeyId,
  string secretAccessKey,
  string region,
  string service
) {
  auto amzDatetime = getAWSDatetime();
  auto amzDate = getAWSDate();
  auto hashedPayload = sha256Hash(payload);

  // Step 1: Create canonical request
  string canonicalMethod = method;
  string canonicalUri = uri.length == 0 ? "/" : uri;
  string canonicalQueryString = queryString;
  
  string canonicalHeaders = format("host:%s\nx-amz-content-sha256:%s\nx-amz-date:%s\n",
    host, hashedPayload, amzDatetime);
  
  string signedHeaders = "host;x-amz-content-sha256;x-amz-date";
  
  string canonicalRequest = format("%s\n%s\n%s\n%s\n%s\n%s",
    canonicalMethod,
    canonicalUri,
    canonicalQueryString,
    canonicalHeaders,
    signedHeaders,
    hashedPayload
  );

  // Step 2: Create string to sign
  string hashedCanonicalRequest = sha256Hash(canonicalRequest);
  string credentialScope = format("%s/%s/%s/aws4_request", amzDate, region, service);
  string stringToSign = format("AWS4-HMAC-SHA256\n%s\n%s\n%s",
    amzDatetime,
    credentialScope,
    hashedCanonicalRequest
  );

  // Step 3: Calculate signature
  string kDate = hmacSha256("AWS4" ~ secretAccessKey, amzDate);
  string kRegion = hmacSha256(kDate, region);
  string kService = hmacSha256(kRegion, service);
  string kSigning = hmacSha256(kService, "aws4_request");
  string signature = hmacSha256(kSigning, stringToSign);

  // Step 4: Create authorization header
  string authHeader = format("AWS4-HMAC-SHA256 Credential=%s/%s, SignedHeaders=%s, Signature=%s",
    accessKeyId,
    credentialScope,
    signedHeaders,
    signature
  );

  return authHeader;
}
