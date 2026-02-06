module uim.google.distributedcloud.resources;

import std.json : Json;
import std.string : format;

import uim.google.distributedcloud.client;
import uim.google.distributedcloud.config;

// Cluster Operations

Json listClusters(GDCClient client, string location = "") {
  return client.listClusters(location);
}

Json getCluster(GDCClient client, string clusterName, string location = "") {
  auto loc = location.length > 0 ? location : client.config.region;
  auto path = format("v1/projects/%s/locations/%s/clusters/%s",
    client.config.projectId, loc, clusterName);
  return client.get(path);
}

// Node Operations

Json listNodes(GDCClient client, string location = "") {
  return client.listNodes(location);
}

Json getNode(GDCClient client, string nodeName, string location = "") {
  auto loc = location.length > 0 ? location : client.config.region;
  auto path = format("v1/projects/%s/locations/%s/nodes/%s",
    client.config.projectId, loc, nodeName);
  return client.get(path);
}

// Machine Learning Operations

Json listModels(GDCClient client, string location = "") {
  return client.listMachineLearningModels(location);
}

Json getModel(GDCClient client, string modelName, string location = "") {
  auto loc = location.length > 0 ? location : client.config.region;
  auto path = format("v1/projects/%s/locations/%s/models/%s",
    client.config.projectId, loc, modelName);
  return client.get(path);
}

// Data Analytics Operations

Json listDatasets(GDCClient client, string location = "") {
  auto loc = location.length > 0 ? location : client.config.region;
  auto path = format("v1/projects/%s/locations/%s/datasets", client.config.projectId, loc);
  return client.get(path);
}

Json listAnalyticsJobs(GDCClient client, string location = "") {
  auto loc = location.length > 0 ? location : client.config.region;
  auto path = format("v1/projects/%s/locations/%s/analyticsjobs", client.config.projectId, loc);
  return client.get(path);
}

// Edge Networking Operations

Json listNetworks(GDCClient client, string location = "") {
  auto loc = location.length > 0 ? location : client.config.region;
  auto path = format("v1/projects/%s/locations/%s/networks", client.config.projectId, loc);
  return client.get(path);
}

Json listSubnets(GDCClient client, string networkName, string location = "") {
  auto loc = location.length > 0 ? location : client.config.region;
  auto path = format("v1/projects/%s/locations/%s/networks/%s/subnets",
    client.config.projectId, loc, networkName);
  return client.get(path);
}
