# UIM GCP Library

A D language library for working with Google Cloud Platform (GCP) using the uim-framework and vibe.d.

## Features

- Google Cloud Platform API HTTP client with vibe.d
- OAuth2 authentication with service account JSON keys
- Compute Engine (VM) management
- Cloud Storage (Bucket) operations
- Cloud Run services
- JSON serialization/deserialization for API responses
- Project and region configuration

## Building

```bash
cd gcp
dub build
```

## Usage

```d
import uim.gcp;

void main() {
  auto cfg = defaultConfig("MY_PROJECT_ID", "SERVICE_ACCOUNT_KEY.json");
  auto client = new GCPClient(cfg);
  
  auto instances = client.computeListInstances("us-central1-a");
  writeln(instances);
}
```

## Configuration

Requires:
- GCP Project ID
- Service account JSON key file path or JSON content

Authentication uses OAuth2 with service account credentials.

## Notes

- Default base URL: https://www.googleapis.com
- Supports multiple GCP services (Compute, Storage, Run, etc.)
- JWT token generation for OAuth2 flow

## License

Apache 2.0
