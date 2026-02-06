module uim.podman.helpers.environment;

/// Creates environment variables array from key-value pairs.
Json createEnvironment(string[string] envMap) {
  Json[] envArray;
  foreach (key, value; envMap) {
    envArray ~= Json(key ~ "=" ~ value);
  }
  return Json(envArray);
}