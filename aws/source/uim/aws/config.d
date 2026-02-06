module uim.aws.config;

struct AWSConfig {
  string accessKeyId;
  string secretAccessKey;
  string region;
  string service;
}

AWSConfig defaultConfig(string accessKeyId = "", string secretAccessKey = "", string region = "us-east-1") {
  AWSConfig cfg;
  cfg.accessKeyId = accessKeyId;
  cfg.secretAccessKey = secretAccessKey;
  cfg.region = region;
  cfg.service = "ec2";
  return cfg;
}

AWSConfig ec2Config(string accessKeyId, string secretAccessKey, string region = "us-east-1") {
  auto cfg = defaultConfig(accessKeyId, secretAccessKey, region);
  cfg.service = "ec2";
  return cfg;
}

AWSConfig s3Config(string accessKeyId, string secretAccessKey, string region = "us-east-1") {
  auto cfg = defaultConfig(accessKeyId, secretAccessKey, region);
  cfg.service = "s3";
  return cfg;
}
