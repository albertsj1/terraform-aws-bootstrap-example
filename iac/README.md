# Terraform IAC

The code in the root of this IAC directory will create a Fargate ECS cluster, RDS Postres db, ALB, and other supporting resources. This code depends on resources created in the account_setup01 and account_setup02 directories to run.

## Pre-requisites

1. Latest version of Terraform
2. aws cli tools installed and configured with an AWS profile that has privileges to create all of the Terraform resources
3. Docker installed and running.  ie. `docker ps` command should work.

## Confirming AWS Configuration

1. Open this directory in a terminal.
2. Ensure the aws profile you want to use is active and works with the us-east-2 region without passing any additional parameters.
3. Running `aws sts get-caller-identity` should work properly without any additional parameters.

## Running Terraform

The code in this root IAC folder depends on the Terraform being run in account_setup01 and account_setup02 first.

### Running account_setup01 Terraform

1. Open terminal in [account_setup01](account_setup01) folder
2. `terraform init -var 'bucket_name=myuniquebucketname' -var 'app_name=myapp' -out setup01.plan`
3. Review the plan and run the next step when ready to create the resources.
4. `terraform apply setup01.plan`

For additional details, see [account_setup01/README.md](account_setup01/README.md).

### Running account_setup02 Terraform

1. Open terminal in [account_setup02](account_setup02) folder
2. `terraform init -var 'app_name=myapp' -out setup02.plan`
3. Review the plan and run the next step when ready to create the resources.
4. `terraform apply setup02.plan`

For additional details, see [account_setup02/README.md](account_setup02/README.md).

### Upload a docker image to ECR

The Terraform code you ran in the account_setup02 folder created a file named `docker_build_push.sh` in the root folder of this git repository.

1. Open terminal in the root of this git repository
2. `./docker_build_push.sh`

This will take a while, but you should see at the end, a docker image being pushed to ECR.

### Run root IAC folder Terraform

Finally.... this is the IAC you were looking for. :) This creates a application load balancer, security groups, and an ECS cluster running the app.

**FIRST**: Open the [terraform.tfvars](terraform.tfvars) in your favorite editor.  Update the `app_name`, `ecr_image_tag`, and `alb_allowed_list`.

1. Open terminal in [this iac directory](./).
2. `terraform init`
3. `terraform apply`
4. Review the plan output and type 'yes' when ready.

This will take a while, but should finish successfully.

## Testing

You'll find a [test.http file](../test.http) in the root of this repository that can be used to easily test the Bunny REST API within VSCode if you have the [REST Client extension][extension] installed.

1. open the [test.http file](../test.http).
2. You'll need to change the @baseUrl variable to point to the load balancer you just created.  You'll find the load balancer dns name near the end of the `terraform apply` output... or...

```bash
# If you're on a mac
terraform output -json | jq -r '.baseurl.value' | pbcopy
```

and paste the value for @baseUrl

Finally... click on send request in the file in the different sections to send different requests. The response should show in a separate window on the right side.

[extension]: https://marketplace.visualstudio.com/items?itemName=humao.rest-client
