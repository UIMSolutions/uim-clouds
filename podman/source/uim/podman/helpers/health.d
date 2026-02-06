module uim.podman.helpers.health;

import uim.podman;
@safe:

/// Creates health check configuration.
Json createHealthCheck(string[] testCmd, int interval = 30, int timeout = 10, int retries = 3, int startPeriod = 0) {
  Json healthCheck = Json([
    "Test": Json(testCmd),
    "Interval": Json(interval * 1_000_000_000L),  // Convert to nanoseconds
    "Timeout": Json(timeout * 1_000_000_000L),
    "Retries": Json(retries),
    "StartPeriod": Json(startPeriod * 1_000_000_000L)
  ]);
  return healthCheck;
}