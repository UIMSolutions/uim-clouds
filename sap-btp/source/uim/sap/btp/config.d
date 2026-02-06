module uim.sap.btp.config;

struct SAPBTPConfig {
  string tenant;
  string subdomain;
  string region;
  string username;
  string password;
  string clientId;
  string clientSecret;
  string accessToken;
  string tokenType = "Bearer";
  bool useOAuth2 = false;
}

SAPBTPConfig defaultConfig(
  string tenant,
  string subdomain,
  string region = "api.sap.hana.ondemand.com"
) {
  SAPBTPConfig cfg;
  cfg.tenant = tenant;
  cfg.subdomain = subdomain;
  cfg.region = region;
  return cfg;
}

SAPBTPConfig oAuth2Config(
  string tenant,
  string subdomain,
  string clientId,
  string clientSecret,
  string region = "api.sap.hana.ondemand.com"
) {
  auto cfg = defaultConfig(tenant, subdomain, region);
  cfg.clientId = clientId;
  cfg.clientSecret = clientSecret;
  cfg.useOAuth2 = true;
  return cfg;
}

string getBaseUrl(ref SAPBTPConfig cfg) {
  if (cfg.subdomain.length > 0) {
    return "https://" ~ cfg.subdomain ~ "." ~ cfg.region;
  }
  return "https://" ~ cfg.region;
}
