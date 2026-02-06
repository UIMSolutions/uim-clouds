module uim.sap.btp.resources;

import std.json : Json;
import std.string : format;

import uim.sap.btp.client;
import uim.sap.btp.config;

// Cloud Foundry Operations

Json listApplications(SAPBTPClient client) {
  return client.getApplications();
}

Json listSpaces(SAPBTPClient client) {
  return client.getSpaces();
}

Json listOrganizations(SAPBTPClient client) {
  return client.getOrganizations();
}

Json listServices(SAPBTPClient client) {
  return client.get("/v2/services", null, "cf");
}

Json listServiceInstances(SAPBTPClient client) {
  return client.get("/v2/service_instances", null, "cf");
}

Json getApplication(SAPBTPClient client, string appGuid) {
  auto path = format("/v2/apps/%s", appGuid);
  return client.get(path, null, "cf");
}

// Destination Operations

Json listDestinations(SAPBTPClient client) {
  return client.get("/destination-configuration/v1/destinations", null, "service");
}

Json getDestination(SAPBTPClient client, string destinationName) {
  auto path = format("/destination-configuration/v1/destinations/%s", destinationName);
  return client.get(path, null, "service");
}

// Environment Operations

Json getEnvironment(SAPBTPClient client) {
  return client.get("/platform/v1/environments", null);
}

Json getSubaccounts(SAPBTPClient client) {
  return client.get("/accounts/v1/subaccounts", null);
}
