module uim.aws.resources;

import std.json : Json;

import uim.aws.client;
import uim.aws.config;

// EC2 Operations

Json describeInstances(AWSClient client) {
  return client.ec2DescribeInstances();
}

Json describeSecurityGroups(AWSClient client) {
  auto query = ["Action": "DescribeSecurityGroups", "Version": "2016-11-15"];
  return client.get("", query);
}

Json describeVolumes(AWSClient client) {
  auto query = ["Action": "DescribeVolumes", "Version": "2016-11-15"];
  return client.get("", query);
}

// S3 Operations

Json listBuckets(AWSClient client) {
  return client.get("/", null);
}

Json listObjects(AWSClient client, string bucket, string prefix = "") {
  auto query = prefix.length > 0 ? ["prefix": prefix] : null;
  return client.get("/" ~ bucket, query);
}
