# UIM Azure Library

A D language library for working with Microsoft Azure using the uim-framework and vibe.d.

## Features

- Azure Resource Manager (ARM) HTTP client
- Subscription and resource group helpers
- Generic GET/POST helpers for ARM endpoints
- JSON serialization/deserialization for API responses

## Building

```bash
cd azure
dub build
```

## Usage

```d
import uim.azure;

void main() {
  auto cfg = defaultConfig("MY_TOKEN", "SUBSCRIPTION_ID");
  auto client = new AzureClient(cfg);
  auto groups = listResourceGroups(client);
  writeln(groups);
}
```

## Notes

- Access tokens must be provided by the caller (AAD OAuth2).
- Default base URL: https://management.azure.com

## License

Apache 2.0
