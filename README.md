# Example Terraform Account Bootstrap and Simple ECS Fargate Cluster

This is an example repository showing how to use Terraform to bootstrap an AWS account and deploy a simple ECS Fargate cluster.  I originally wrote this for an interview a while ago and decided to open source it.  Feel free to open issues and/or contribute.

After following all of the instructions in the [iac/README.md][iac_readme], you will have a working ECS Fargate cluster with a small Python server that provides a simple API that will return the Fibonnaci servies for the passed number.  See [test.http](./test.http) for examples.  There is also a /health endpoint.

A [pre-commit](https://pre-commit.com) configuration is provided as well as an [included Github action](.github/workflows/pull_request.yml) to build and run tests when a pull request is created.

## Getting Started

After completing all of the steps outlined in each of the README files, the following AWS resources will be created:

- VPC
- Public and Private VPC Subnets
- NAT Gateway
- ECR Repository
- S3 Bucket
- KMS Key
- Dynamodb table
- ECR Fargate Cluster
- ALB
- Security Groups
- IAM Policies and Roles

### Optional

#### Setup pre-commit

1. `brew install pre-commit` or follow [pre-commit installation instructions](https://pre-commit.com/#install)
2. `pre-commit install`

### AWS

See [iac/README.md][iac_readme].

#### Testing

Simply use curl against the load balancer created by the IaC code above.

```sh
curl -i http://<load balancer dns>:8000/?n=10
```

## Development

Requires:

- Python 3.12
- PDM

While in the project root directory:

```sh
# Install pdm
pipx install pdm

# Install dependencies, including dev dependenceis
pdm install -d
```

To run the server, simply run `pdm start`

## License

This project uses the [GNU GPLv3 license](https://choosealicense.com/licenses/gpl-3.0/).

[iac_readme]: iac/README.md
