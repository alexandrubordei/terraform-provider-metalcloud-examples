/* 
An example showing how to deploy an infrastructure with servers but with no OS on them 
Useful when the OS installed is performed by another solution such as AWS EKS Anywhere
or Dell PowerFlex Manager 
*/

terraform {
  required_providers {
    metalcloud = {
      source = "metalsoft-io/metalcloud"
       version = ">= 2.2.7"
    }
  }
}

check "vars"{
 assert {
    condition = var.user_email!=""
    error_message = "user email variable cannot be empty"
  }
}

provider "metalcloud" {
   user_email = var.user_email
   api_key = var.api_key
   endpoint = var.endpoint

}

# This is an infrastructure reference. It is needed to avoid a cyclic dependency where the 
# infrastructure depends on the resources and vice-versa. This will create the infrastructure if it does not exist
# if the create_if_not_exists flag is set to true
data "metalcloud_infrastructure" "infra" {
   
    infrastructure_label = "infra-import-tests"
    datacenter_name = "${var.datacenter}" 

    create_if_not_exists = true
}

resource "metalcloud_network" "wan" {
    infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
    network_label = "data-network"
    network_type = "wan"
}

resource "metalcloud_network" "lan" {
    infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
    network_label = "lan-network"
    network_type = "lan"
}

resource "metalcloud_network" "lan2" {
    infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
    network_label = "lan2-network"
    network_type = "lan"
}

data "metalcloud_server_type" "hci1"{
  server_type_name = "M.96.544.7"

}

data "metalcloud_network_profile" "wan"{
    network_profile_label = "pf-wan"
    datacenter_name = var.datacenter
}


data "metalcloud_network_profile" "lan"{
    network_profile_label = "default-lan"
    datacenter_name = var.datacenter
}


data "metalcloud_network_profile" "lan2"{
    network_profile_label = "default-lan2"
    datacenter_name = var.datacenter
}


resource "metalcloud_instance_array" "srv1" {

    infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id

    instance_array_label = "srv1"

    instance_array_instance_count = 1 //deprecated, keep equal to 1

    instance_server_type{
      instance_index=0
      server_type_id=data.metalcloud_server_type.hci1.server_type_id
    }

    //volume_template_id = tonumber(data.metalcloud_volume_template.esxi7.id)

    instance_array_firewall_managed = false

    interface{
      interface_index = 0
      network_id = metalcloud_network.wan.id
    }

    interface{
      interface_index = 1
      network_id = metalcloud_network.lan.id
    }

    interface{
      interface_index = 2
      network_id = metalcloud_network.lan.id
    }

    interface{
      interface_index = 3
      network_id = metalcloud_network.lan2.id
    }


    network_profile {
      network_id = metalcloud_network.wan.id
      network_profile_id = data.metalcloud_network_profile.wan.id
    }

    network_profile {
      network_id = metalcloud_network.lan.id
      network_profile_id = data.metalcloud_network_profile.lan.id
    }

    
    network_profile {
      network_id = metalcloud_network.lan2.id
      network_profile_id = data.metalcloud_network_profile.lan2.id
    }

}


resource "metalcloud_instance_array" "srv2" {

    infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id

    instance_array_label = "srv2"

    instance_array_instance_count = 1 //deprecated, keep equal to 1

    instance_server_type{
      instance_index=0
      server_type_id=data.metalcloud_server_type.hci1.server_type_id
    }

    //volume_template_id = tonumber(data.metalcloud_volume_template.esxi7.id)

    instance_array_firewall_managed = false

   interface{
      interface_index = 0
      network_id = metalcloud_network.wan.id
    }

    interface{
      interface_index = 1
      network_id = metalcloud_network.lan.id
    }

    interface{
      interface_index = 2
      network_id = metalcloud_network.lan.id
    }

    interface{
      interface_index = 3
      network_id = metalcloud_network.lan2.id
    }


    network_profile {
      network_id = metalcloud_network.wan.id
      network_profile_id = data.metalcloud_network_profile.wan.id
    }

    network_profile {
      network_id = metalcloud_network.lan.id
      network_profile_id = data.metalcloud_network_profile.lan.id
    }
    
    network_profile {
      network_id = metalcloud_network.lan2.id
      network_profile_id = data.metalcloud_network_profile.lan2.id
    }
}

resource "metalcloud_instance_array" "srv3" {

    infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id

    instance_array_label = "srv3"

    instance_array_instance_count = 1 //deprecated, keep equal to 1

    instance_server_type{
      instance_index=0
      server_type_id=data.metalcloud_server_type.hci1.server_type_id
    }

    //volume_template_id = tonumber(data.metalcloud_volume_template.esxi7.id)

    instance_array_firewall_managed = false

   interface{
      interface_index = 0
      network_id = metalcloud_network.wan.id
    }

    interface{
      interface_index = 1
      network_id = metalcloud_network.lan.id
    }

    interface{
      interface_index = 2
      network_id = metalcloud_network.lan.id
    }

    interface{
      interface_index = 3
      network_id = metalcloud_network.lan2.id
    }


    network_profile {
      network_id = metalcloud_network.wan.id
      network_profile_id = data.metalcloud_network_profile.wan.id
    }

    network_profile {
      network_id = metalcloud_network.lan.id
      network_profile_id = data.metalcloud_network_profile.lan.id
    }

    
    network_profile {
      network_id = metalcloud_network.lan2.id
      network_profile_id = data.metalcloud_network_profile.lan2.id
    }

}


resource "metalcloud_instance_array" "srv4" {

    infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id

    instance_array_label = "srv4"

    instance_array_instance_count = 1 //deprecated, keep equal to 1

    instance_server_type{
      instance_index=0
      server_type_id=data.metalcloud_server_type.hci1.server_type_id
    }

    //volume_template_id = tonumber(data.metalcloud_volume_template.esxi7.id)

    instance_array_firewall_managed = false

    interface{
      interface_index = 0
      network_id = metalcloud_network.wan.id
    }

    interface{
      interface_index = 1
      network_id = metalcloud_network.lan.id
    }

    interface{
      interface_index = 2
      network_id = metalcloud_network.lan.id
    }

    interface{
      interface_index = 3
      network_id = metalcloud_network.lan2.id
    }

    network_profile {
      network_id = metalcloud_network.wan.id
      network_profile_id = data.metalcloud_network_profile.wan.id
    }

    network_profile {
      network_id = metalcloud_network.lan.id
      network_profile_id = data.metalcloud_network_profile.lan.id
    }

    
    network_profile {
      network_id = metalcloud_network.lan2.id
      network_profile_id = data.metalcloud_network_profile.lan2.id
    }
    
}


data "metalcloud_workflow_task" "PowerFlex" {
    stage_definition_label = "deploy-pf-hci"
}
# Use this resource to effect deploys of the above resources.
resource "metalcloud_infrastructure_deployer" "infrastructure_deployer" {

  infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id

  # Set this to false to actually trigger deploys.
  prevent_deploy = true

  # These options will make terraform apply operation will wait for the deploy to finish (when prevent_deploy is false)
  # instead of exiting while the deploy is ongoing

  await_deploy_finished = true

  # This option disables a safety check that metalsoft performs to prevent accidental data loss
  # It is required when testing delete operations

  allow_data_loss = true
  /*
  workflow_task {
    stage_definition_id = data.metalcloud_workflow_task.PowerFlex.id
    run_level = 0
    stage_run_group = "post_deploy"
  }
  */
  # IMPORTANT. This is important to ensure that deploys happen after everything else. If you need to add or remove resources dynamically
  # use either count or for_each in the resources or move everything that is dynamic into a module and make this depend on the module
  depends_on = [
    metalcloud_instance_array.srv1,
    metalcloud_instance_array.srv2,
    metalcloud_instance_array.srv3,
    metalcloud_instance_array.srv4,
  ]
  

}

data "metalcloud_infrastructure_output" "output"{
    infrastructure_id = data.metalcloud_infrastructure.infra.id
    depends_on = [ resource.metalcloud_infrastructure_deployer.infrastructure_deployer ]
}

output "credentials" {
    value = jsondecode(data.metalcloud_infrastructure_output.output.instances)
}

variable "user_email" {
  default = ""
}

variable "api_key" {
  default = ""
}

variable "endpoint" {
  default =""
}

variable "datacenter" {
  default=""
}
