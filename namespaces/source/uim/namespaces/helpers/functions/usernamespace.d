module uim.namespaces.helpers.functions.usernamespace;

import uim.namespaces;
@safe:

/// Creates a user namespace configuration with standard UID/GID mappings
UserNamespaceConfig createStandardUserNamespace(uint insideUid = 0, uint insideGid = 0) {
  UserNamespaceConfig config;
  
  IDMapping uidMap;
  uidMap.insideId = insideUid;
  uidMap.outsideId = 0;
  uidMap.rangeSize = 65536;
  config.uidMappings ~= uidMap;
  
  IDMapping gidMap;
  gidMap.insideId = insideGid;
  gidMap.outsideId = 0;
  gidMap.rangeSize = 65536;
  config.gidMappings ~= gidMap;
  
  config.denySetgroups = false;
  
  return config;
}

/// Creates a user namespace configuration with nested UID/GID ranges
UserNamespaceConfig createNestedUserNamespace(
  uint outerMinUid = 100000,
  uint outerMinGid = 100000,
  uint rangeSize = 65536
) {
  UserNamespaceConfig config;
  
  IDMapping uidMap;
  uidMap.insideId = 0;
  uidMap.outsideId = outerMinUid;
  uidMap.rangeSize = rangeSize;
  config.uidMappings ~= uidMap;
  
  IDMapping gidMap;
  gidMap.insideId = 0;
  gidMap.outsideId = outerMinGid;
  gidMap.rangeSize = rangeSize;
  config.gidMappings ~= gidMap;
  
  config.denySetgroups = true;
  
  return config;
}

