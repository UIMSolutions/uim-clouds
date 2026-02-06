module uim.google.distributedcloud.config;

import std.json : Json, parseJSON;
import std.file : readText;

struct GDCConfig {
  string projectId;
  string privateKeyId;
  string privateKey;
  string clientEmail;
  string clientId;
  string authUri;
  string tokenUri;
  string authProviderCertUrl;
  string clientCertUrl;
  string accessToken;
  string region;
  string edgeLocation;
}

GDCConfig defaultConfig(string projectId, string serviceKeyPath = "") {
  GDCConfig cfg;
  cfg.projectId = projectId;
  cfg.authUri = "https://accounts.google.com/o/oauth2/auth";
  cfg.tokenUri = "https://oauth2.googleapis.com/token";
  cfg.authProviderCertUrl = "https://www.googleapis.com/oauth2/v1/certs";
  cfg.region = "us-west1";
  
  if (serviceKeyPath.length > 0) {
    loadServiceAccountKey(cfg, serviceKeyPath);
  }
  
  return cfg;
}

void loadServiceAccountKey(ref GDCConfig cfg, string keyPath) {
  try {
    auto content = readText(keyPath);
    auto json = parseJSON(content);
    
    cfg.projectId = json["project_id"].str;
    cfg.privateKeyId = json["private_key_id"].str;
    cfg.privateKey = json["private_key"].str;
    cfg.clientEmail = json["client_email"].str;
    cfg.clientId = json["client_id"].str;
    cfg.authUri = json["auth_uri"].str;
    cfg.tokenUri = json["token_uri"].str;
    cfg.authProviderCertUrl = json["auth_provider_x509_cert_url"].str;
    cfg.clientCertUrl = json["client_x509_cert_url"].str;
  } catch (Exception e) {
    // Handle error silently or log
  }
}

GDCConfig withRegion(GDCConfig cfg, string region) {
  cfg.region = region;
  return cfg;
}

GDCConfig withEdgeLocation(GDCConfig cfg, string location) {
  cfg.edgeLocation = location;
  return cfg;
}
