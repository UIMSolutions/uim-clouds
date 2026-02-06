# UIM Google Distributed Cloud Library

A D language library for working with Google Distributed Cloud (GDC) using the uim-framework and vibe.d.

## Features

- Google Distributed Cloud API HTTP client with vibe.d
- OAuth2 authentication with service account JSON keys
- Edge compute and on-premises operations
- Cluster and node management
- Machine learning and data analytics operations
- JSON serialization/deserialization for API responses
- Multi-region and edge location support

## Building

```bash
cd google-distributedcloud
dub build
```

## Usage

```d
import uim.google.distributedcloud;

void main() {
  auto cfg = defaultConfig("MY_PROJECT_ID", "SERVICE_ACCOUNT_KEY.json");
  auto client = new GDCClient(cfg);
  
  auto clusters = client.listClusters("us-west1");
  writeln(clusters);
}
```

## Configuration

Requires:
- GCP Project ID
- Service account JSON key file path or JSON content
- Optional: Edge location and region specification

## Google Distributed Cloud Services

- **Distributed Cloud Edge**: Edge computing at the edge
- **Distributed Cloud VMware**: On-premises VMware infrastructure
- **Machine Learning**: ML operations at the edge
- **Data Analytics**: Analytics at the edge
- **Networking**: Edge networking and connectivity

## Notes

- Default base URL: https://googleapis.com
- Supports service account authentication
- Multi-region and edge location aware
- Integrates with Google Cloud ecosystem

## License

Apache 2.0
