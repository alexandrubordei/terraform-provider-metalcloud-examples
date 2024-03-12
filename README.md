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


