/*
In this example MetalSoft's VSPhere application is deployed.
*/

terraform {
  required_providers {
    metalcloud = {
      source = "metalsoft-io/metalcloud"
      version = "2.5.10"
    }
  }
}
 
provider "metalcloud" {
  //  user_email = var.user_email
  //  api_key = var.api_key
  //  endpoint = var.endpoint
   user_email = "srinath.chandra@sc.com"
   api_key = "13:JiKSP4h8Obdt1KVKj4a2YiLzzJypi1HfcMlP9O2sX9hoR9Ev554aTFkIaEMcJaJ"
   endpoint = "https://us10.metalsoft.io/api/developer/developer"
}
 
variable "datacenter" {
  description = "The datacenter id"
  type        = string
  default     = "scb-dc"
}
 
# variable "server_name" {
#   description = "The server name"
#   type        = string
# }
 
variable "infra_label" {
  description = "The infra label"
  type        = string
  default     = "vmware-infra-test"
}
 
variable "instance_array_label" {
  description = "The instance array label"
  type        = string
  default     = "vmware-infra-test-array"
}
 
# This is an infrastructure reference. It is needed to avoid a cyclic dependency where the 
# infrastructure depends on the resources and vice-versa. This will create the infrastructure if it does not exist
# if the create_if_not_exists flag is set to true
data "metalcloud_infrastructure" "infra" {
   
    infrastructure_label = "vmware-infra-test"
    datacenter_name = var.datacenter 
 
    create_if_not_exists = true
}
 
data "metalcloud_server_type" "large"{
     server_type_name = "M.64.512.10"
}
 
resource "metalcloud_network" "wan" {
    infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
    network_type = "wan"
}
 
resource "metalcloud_network" "lan1" {
    infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
    network_type = "lan"
}
 
resource "metalcloud_network" "lan2" {
    infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
    network_type = "lan"
}
 
resource "metalcloud_network" "lan3" {
    infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
    network_type = "lan"
}
 
data "metalcloud_network_profile" "vmware_wan"{
    network_profile_label = "vmware-cluster"
    datacenter_name = var.datacenter
}
 
data "metalcloud_network_profile" "vmware_lan"{
    network_profile_label = "vmware-cluster-lan"
    datacenter_name = var.datacenter
}
 
resource "metalcloud_vmware_vsphere" "VMWareVsphere" {
    infrastructure_id =  data.metalcloud_infrastructure.infra.infrastructure_id
 
    cluster_label = "testvmware"
    instance_array_instance_count_master = 1
    instance_array_instance_count_worker = 2
 
    instance_server_type_master {
        instance_index = 0
        server_type_id = data.metalcloud_server_type.large.server_type_id
    }
 
    instance_server_type_worker {
        instance_index = 0
        server_type_id = data.metalcloud_server_type.large.server_type_id
    }
 
    instance_server_type_worker {
        instance_index = 1
        server_type_id = data.metalcloud_server_type.large.server_type_id
    }
 
 
    interface_master{
      interface_index = 0
      network_id = metalcloud_network.wan.id
    }
 
    interface_master{
      interface_index = 1
      network_id = metalcloud_network.lan1.id
    }
 
    interface_master {
      interface_index = 2
      network_id = metalcloud_network.lan2.id
    }
 
    interface_master {
      interface_index = 3
      network_id = metalcloud_network.lan3.id
    }
 
    interface_worker{
      interface_index = 0
      network_id = metalcloud_network.wan.id
    }
 
    interface_worker {
      interface_index = 1
      network_id = metalcloud_network.lan1.id
    }
 
    interface_worker {
      interface_index = 2
      network_id = metalcloud_network.lan2.id
    }
 
    interface_worker {
      interface_index = 3
      network_id = metalcloud_network.lan3.id
    }
 
    instance_array_network_profile_master {
        network_id = metalcloud_network.wan.id
        network_profile_id = data.metalcloud_network_profile.vmware_wan.id
    }
 
    instance_array_network_profile_master {
        network_id = metalcloud_network.lan1.id
        network_profile_id = data.metalcloud_network_profile.vmware_lan.id
    }
 
    instance_array_network_profile_master {
        network_id = metalcloud_network.lan2.id
        network_profile_id = data.metalcloud_network_profile.vmware_lan.id
    }
 
    instance_array_network_profile_master {
        network_id = metalcloud_network.lan3.id
        network_profile_id = data.metalcloud_network_profile.vmware_lan.id
    }
 
    instance_array_network_profile_worker {
        network_id = metalcloud_network.wan.id
        network_profile_id = data.metalcloud_network_profile.vmware_wan.id
    }
 
    instance_array_network_profile_worker {
        network_id = metalcloud_network.lan1.id
        network_profile_id = data.metalcloud_network_profile.vmware_lan.id
    }
 
    instance_array_network_profile_worker {
        network_id = metalcloud_network.lan2.id
        network_profile_id = data.metalcloud_network_profile.vmware_lan.id
    }
 
    instance_array_network_profile_worker {
        network_id = metalcloud_network.lan3.id
        network_profile_id = data.metalcloud_network_profile.vmware_lan.id
    }
 
    instance_array_custom_variables_master = {      
        "vcsa_ip"= "192.168.177.2",
        "vcsa_gateway"= "192.168.177.1",
        "vcsa_netmask"= "255.255.255.0"
    }
}
 
# data "metalcloud_volume_template" "esxi7" {
#   volume_template_label = "esxi-700-uefi-v2"
# }
 
# resource "metalcloud_network" "data" {
#     infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
#     network_label = "data-network"
#     network_type = "wan"
# }
 
# resource "metalcloud_network" "storage" {
#     infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
#     network_label = "storage-network"
#     network_type = "san"
# }
 
# data "metalcloud_server_type" "large" {
#   server_type_name = var.server_name
# }
 
# resource "metalcloud_instance_array" "cluster" {
 
#     infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
 
#     instance_array_label = var.instance_array_label
 
#     instance_array_instance_count = 3 //deprecated, keep equal to 1
#     instance_array_boot_method = "local_drives"
 
#     // instance_server_type{
#     //   instance_index=0
#     //   server_type_id=data.metalcloud_server_type.large.server_type_id
#     // }
 
#     volume_template_id = tonumber(data.metalcloud_volume_template.esxi7.id)
 
#     instance_array_firewall_managed = false
 
#     interface{
#       interface_index = 0
#       network_id = metalcloud_network.data.id
#     }
 
#     interface{
#       interface_index = 1
#       network_id = metalcloud_network.storage.id
#     }
 
#     instance_custom_variables {
#       instance_index = 0
#       custom_variables={
#         "test1":"test2"
#         "test3":"test4"
#       }
#     }
 
#     // firewall_rule {
#     //         firewall_rule_description = "allow ssh from internet machine"
#     //         firewall_rule_port_range_start = 22
#     //         firewall_rule_port_range_end = 22
#     //         firewall_rule_source_ip_address_range_start="49.205.134.5"
#     //         firewall_rule_source_ip_address_range_end="49.205.134.5"
#     //         firewall_rule_protocol="tcp"
#     //         firewall_rule_ip_address_type="ipv4"
#     // }
# }
 
# resource "metalcloud_shared_drive" "datastore" {
 
#     infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
  
#     shared_drive_label = "esxi-shared-drive"
#     shared_drive_size_mbytes = 10240
#     shared_drive_storage_type = "iscsi_ssd"
 
#     shared_drive_attached_instance_arrays = [metalcloud_instance_array.cluster.instance_array_id]  //this will create a dependency on the instance array
# }
 
 
# Use this resource to effect deploys of the above resources.
resource "metalcloud_infrastructure_deployer" "infrastructure_deployer" {
 
  infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
 
  # Set this to false to actually trigger deploys.
  prevent_deploy = false
 
  #these options will make terraform apply operation will wait for the deploy to finish (when prevent_deploy is false)
  #instead of exiting while the deploy is ongoing
 
  await_deploy_finished = false
 
  #this option disables a safety check that MetalSoft performs to prevent accidental data loss
  #it is required when testing delete operations
 
  allow_data_loss = true
 
  # IMPORTANT. This is important to ensure that deploys happen after everything else. If you need to add or remove resources dynamically
  # use either count or for_each in the resources or move everything that is dynamic into a module and make this depend on the module
  depends_on = [
    metalcloud_vmware_vsphere.VMWareVsphere
  ]
}
 
data "metalcloud_infrastructure_output" "output"{
    infrastructure_id = data.metalcloud_infrastructure.infra.id
    depends_on = [ resource.metalcloud_infrastructure_deployer.infrastructure_deployer ]
}
output "cluster_credentials" {
    value = jsondecode(data.metalcloud_infrastructure_output.output.clusters)
}