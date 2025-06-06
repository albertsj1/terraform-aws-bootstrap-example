# Account Setup

The following is needed to be run only once to set up a new AWS account. It will create the following resources in your AWS Account

- vpc
- vpc subnets (public, private)
- ECR repository

## Requirements

1. AWS CLI with credentials configured for the account you want to use.
2. Terraform cli installed
3. Run the Terraform in [account_setup01](../account_setup01/) first.

## Steps

The following assumes you want to use AWS region us-east-2 and you have configured an AWS profile named `myprofile`.

**NOTE: Be sure to use the same value for `app_name` below that you used in account_setup01.**

```bash
export AWS_REGION=us-east-2
export AWS_PROFILE=myprofile

terraform init
terraform plan -var 'app_name=myapp' -out setup02.plan
terraform apply setup02.plan
```

## Next Steps

Follow the instructions in the [iac folder README.md](../README.md).
