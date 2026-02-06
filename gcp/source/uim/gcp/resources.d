module uim.gcp.resources;

import std.json : Json;
import std.string : format;

import uim.gcp.client;
import uim.gcp.config;

// Compute Engine Operations

Json listInstances(GCPClient client, string zone) {
  return client.computeListInstances(zone);
}

Json getInstance(GCPClient client, string zone, string instanceName) {
  auto path = format("compute/v1/projects/%s/zones/%s/instances/%s",
    client.config.projectId, zone, instanceName);
  return client.get(path);
}

Json listZones(GCPClient client) {
  auto path = format("compute/v1/projects/%s/global/zones", client.config.projectId);
  return client.get(path);
}

// Cloud Storage Operations

Json listBuckets(GCPClient client) {
  return client.storageListBuckets();
}

Json listObjects(GCPClient client, string bucket, string prefix = "") {
  auto path = format("storage/v1/b/%s/o", bucket);
  auto query = prefix.length > 0 ? ["prefix": prefix] : null;
  return client.get(path, query);
}

// Cloud Run Operations

Json listServices(GCPClient client, string region = "us-central1") {
  return client.cloudrunListServices(region);
}

Json getService(GCPClient client, string serviceName, string region = "us-central1") {
  auto path = format("v1/projects/%s/locations/%s/services/%s",
    client.config.projectId, region, serviceName);
  return client.get(path);
}
