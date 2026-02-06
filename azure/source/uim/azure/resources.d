module uim.azure.resources;

import std.json : Json;
import std.string : format;

import uim.azure.client;
import uim.azure.config;

Json listSubscriptions(AzureClient client) {
  auto apiVersion = client.config.apiVersion;
  return client.get("subscriptions", ["api-version": apiVersion]);
}

Json listResourceGroups(AzureClient client) {
  auto apiVersion = client.config.apiVersion;
  auto subscriptionId = client.config.subscriptionId;
  auto path = format("subscriptions/%s/resourcegroups", subscriptionId);
  return client.get(path, ["api-version": apiVersion]);
}

Json listResources(AzureClient client, string resourceGroup) {
  auto apiVersion = client.config.apiVersion;
  auto subscriptionId = client.config.subscriptionId;
  auto path = format("subscriptions/%s/resourcegroups/%s/resources", subscriptionId, resourceGroup);
  return client.get(path, ["api-version": apiVersion]);
}

Json getResource(AzureClient client, string resourceId) {
  auto apiVersion = client.config.apiVersion;
  return client.get(resourceId, ["api-version": apiVersion]);
}
