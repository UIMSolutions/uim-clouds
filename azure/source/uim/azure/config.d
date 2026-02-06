module uim.azure.config;

struct AzureConfig {
  string baseUrl;
  string apiVersion;
  string tenantId;
  string subscriptionId;
  string accessToken;
}

AzureConfig defaultConfig(string accessToken = "", string subscriptionId = "", string tenantId = "") {
  AzureConfig cfg;
  cfg.baseUrl = "https://management.azure.com";
  cfg.apiVersion = "2021-04-01";
  cfg.tenantId = tenantId;
  cfg.subscriptionId = subscriptionId;
  cfg.accessToken = accessToken;
  return cfg;
}
