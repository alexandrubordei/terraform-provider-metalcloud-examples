# terraform-provider-metalcloud-examples

The examples in this folder cover different scenarios using MetalSoft's terraform provider. 

The following terraform variables will need to be set:
* `user_email`
* `api_key`
* `endpoint`
* `datacenter`

To set these variables there are a number of options among which the use of the TF_VAR_<variable_name> option. 

Here is an example configuration:
```
export METALCLOUD_API_KEY=9:...
export METALCLOUD_ENDPOINT=https://....metalsoft.io
export METALCLOUD_USER_EMAIL=...
export METALCLOUD_DATACENTER=...
export METALCLOUD_ADMIN=true
export TF_VAR_user_email=$METALCLOUD_USER_EMAIL
export TF_VAR_api_key=$METALCLOUD_API_KEY
export TF_VAR_endpoint="${METALCLOUD_ENDPOINT}/api/developer/developer"
export TF_VAR_datacenter=$METALCLOUD_DATACENTER
export TF_VAR_logging_enabled=true
export TF_LOG=DEBUG
```

## Running terraform

Use the examples like any other terraform project:
```
terraform init
terraform plan
terraform apply
```

## The prevent_deploy flag

Note that the there is a `prevent_deploy` flag on the infrastructure_deployer script. Set this flag to test your infrastructure creation process but not actually deploy it. You can safely run terraform apply as many times as you want while designing your MetalSoft infrastructure. When ready flip the flag to false or comment it out and the infrastructure will deploy the changes on the equipment.


## Destroying an infrastructure

You can safely use `terraform destroy` to delete an infrastructure. 



