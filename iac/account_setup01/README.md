# Account Setup Step 1

If you are provisioning your account, this must be run first. It will provision AWS infra needed to save remote Terraform state. It will also generate a `autogen_state.tf` file in the [account_setup02 directory](../account_setup02/) and the [iac directory](../../iac/).

## Requirements

1. Latest version of AWS CLI configured with a working profile
2. Latest version of Terraform installed

## Steps

The following assumes you want to use AWS region us-east-2 and you have configured an AWS profile named `myprofile`.

Think of a globally unique name for the S3 bucket that will hold the Terraform state files.  Use this as the value for `bucketname` below.  You will also need to pass a value for app_name.  `app_name` is a name used to uniquely identify resources.

```bash
export AWS_REGION=us-east-2
export AWS_PROFILE=myprofile

terraform init
terraform plan -var 'bucket_name=myuniquebucketname' -var 'app_name=myapp' -out setup01.plan
terraform apply setup01.plan
```

## Next Steps

Go to the [account_setup02 direcotry](../account_setup02/) and follow the instructions in the [README](../account_setup02/README.md).
