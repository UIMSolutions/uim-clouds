# UIM AWS Library

A D language library for working with Amazon Web Services (AWS) using the uim-framework and vibe.d.

## Features

- AWS API HTTP client with vibe.d
- AWS Signature Version 4 request signing
- EC2, S3, and other service support
- JSON serialization/deserialization for API responses
- Region and credential configuration

## Building

```bash
cd aws
dub build
```

## Usage

```d
import uim.aws;

void main() {
  auto cfg = defaultConfig("ACCESS_KEY", "SECRET_KEY", "us-east-1");
  auto client = new AWSClient(cfg);
  
  auto instances = client.ec2DescribeInstances();
  writeln(instances);
}
```

## Configuration

Requires AWS access key, secret key, and region. Can be loaded from environment variables or provided explicitly.

## Notes

- Supports AWS Signature Version 4 signing
- Default region: us-east-1
- Endpoints use AWS API URLs (e.g., ec2.amazonaws.com)

## License

Apache 2.0
