/*
In this example MetalSoft's VSPhere application is deployed.
*/

terraform {
  required_providers {
    metalcloud = {
      source = "metalsoft-io/metalcloud"
      version = ">= 2.5.9"
    }
  }
}
 
provider "metalcloud" {
    user_email = var.user_email
    api_key = var.api_key
    endpoint = var.endpoint
   
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
 
# This is an infrastructure reference. It is needed to avoid a cyclic dependency where the 
# infrastructure depends on the resources and vice-versa. This will create the infrastructure if it does not exist
# if the create_if_not_exists flag is set to true
data "metalcloud_infrastructure" "infra" {
   
    infrastructure_label = "vmware-infra-test"
    datacenter_name = var.datacenter 
 
    create_if_not_exists = true
}
 
data "metalcloud_server_type" "large"{
     server_type_name = "M.8.8.3"
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
 
data "metalcloud_network_profile" "vmware_wan"{
    network_profile_label = "cb-vm"
    datacenter_name = var.datacenter
}
 
data "metalcloud_network_profile" "vmware_lan1"{
    network_profile_label = "testlan"
    datacenter_name = var.datacenter
}

data "metalcloud_network_profile" "vmware_lan2"{
    network_profile_label = "testlan"
    datacenter_name = var.datacenter
}
 
resource "metalcloud_vmware_vcf" "cluster01" {
    infrastructure_id =  data.metalcloud_infrastructure.infra.infrastructure_id
 
    cluster_label = "testvmware"
    instance_array_instance_count_mgmt = 1
    instance_array_instance_count_workload = 1
 
    instance_server_type_mgmt {
        instance_index = 0
        server_type_id = data.metalcloud_server_type.large.server_type_id
    }
 
    instance_server_type_workload {
        instance_index = 0
        server_type_id = data.metalcloud_server_type.large.server_type_id
    }
    /*
    [INTERFACE ORDERING] - Control Nodes DIFFERENT NETWORK PROFILES for Control and Workload nodes
    NIC Slot 3
        Port 1: Storage SW1 - IF #5 - VSAN - LAN Network #2 - 
        Port 2: Storage SW2 - IF #7 - VSAN - LAN Network #2
    NIC Slot 4
        Port 1: DATA SW1 - IF #1 - workload, VMOTION - WAN network (workload IP)
        Port 2: DATA SW2 - IF #3 - NSX-workload - LAN Network #1
    NIC Slot 5
        Port 1: DATA SW1 - IF #2 - NSX - LAN Network #1
        Port 2: DATA SW2 - IF #4 - workload, VMOTION - WAN network
    NIC Slot 6
        Port 1: Storage SW1 - IF #6 - VSAN - LAN Network #2
        Port 2: Storage SW2 - IF #8 - VSAN - LAN Network #2

    WAN LAN1 WAN LAN1 LAN2 LAN2 LAN2 LAN2
    */

    //management servers interfaces mapping
    interface_mgmt{
      interface_index = 0
      network_id = metalcloud_network.wan.network_id
    }
 
    interface_mgmt{
      interface_index = 1
      network_id = metalcloud_network.lan1.network_id
    }
 
    interface_mgmt {
      interface_index = 2
      network_id = metalcloud_network.wan.network_id
    }
 
    interface_mgmt {
      interface_index = 3
      network_id = metalcloud_network.lan1.network_id
    }

    interface_mgmt {
      interface_index = 4
      network_id = metalcloud_network.lan2.network_id
    }

    interface_mgmt {
      interface_index = 5
      network_id = metalcloud_network.lan2.network_id
    }

    interface_mgmt {
      interface_index = 6
      network_id = metalcloud_network.lan2.network_id
    }

    interface_mgmt {
      interface_index = 7
      network_id = metalcloud_network.lan2.network_id
    }

    //workload servers interfaces mapping
    interface_workload{
      interface_index = 0
      network_id = metalcloud_network.wan.network_id
    }
 
    interface_workload{
      interface_index = 1
      network_id = metalcloud_network.lan1.network_id
    }
 
    interface_workload {
      interface_index = 2
      network_id = metalcloud_network.wan.network_id
    }
 
    interface_workload {
      interface_index = 3
      network_id = metalcloud_network.lan1.network_id
    }

    interface_workload {
      interface_index = 4
      network_id = metalcloud_network.lan2.network_id
    }

    interface_workload {
      interface_index = 5
      network_id = metalcloud_network.lan2.network_id
    }

    interface_workload {
      interface_index = 6
      network_id = metalcloud_network.lan2.network_id
    }

    interface_workload {
      interface_index = 7
      network_id = metalcloud_network.lan2.network_id
    }

    //management servers network profiles
    instance_array_network_profile_workload {
        network_id = metalcloud_network.wan.network_id
        network_profile_id = data.metalcloud_network_profile.vmware_wan.id
    }
 
    instance_array_network_profile_workload {
        network_id = metalcloud_network.lan1.network_id
        network_profile_id = data.metalcloud_network_profile.vmware_lan1.id
    }
 
    instance_array_network_profile_workload {
        network_id = metalcloud_network.lan2.network_id
        network_profile_id = data.metalcloud_network_profile.vmware_lan2.id
    }
 
 
    //workload servers network profiles
    instance_array_network_profile_workload {
        network_id = metalcloud_network.wan.network_id
        network_profile_id = data.metalcloud_network_profile.vmware_wan.id
    }
 
    instance_array_network_profile_workload {
        network_id = metalcloud_network.lan1.network_id
        network_profile_id = data.metalcloud_network_profile.vmware_lan1.id
    }
 
    instance_array_network_profile_workload {
        network_id = metalcloud_network.lan2.network_id
        network_profile_id = data.metalcloud_network_profile.vmware_lan2.id
    }
 }

data "metalcloud_subnet_pool" "subnetpool1" {
        subnet_pool_label = "vmware-test"
}

data "metalcloud_subnet_pool" "subnetpool2" {
        subnet_pool_label = "vmware-test-normal"
}

resource "metalcloud_subnet" "esxi-mgmt" {
                subnet_type = "ipv4"
                infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
                subnet_label="esxi-mgmt"
                cluster_id = metalcloud_vmware_vcf.cluster01.cluster_id
                network_id = metalcloud_network.wan.network_id
                subnet_pool_id = data.metalcloud_subnet_pool.subnetpool1.subnet_pool_id
                subnet_automatic_allocation = false
                subnet_override_vlan_auto_allocation_index = 1
                subnet_override_vlan_id = 0
                subnet_is_ip_range = true
                subnet_ip_range_ip_count = 30
                subnet_prefix_size = 24
                
}


resource "metalcloud_subnet" "vmotion" {
                subnet_type = "ipv4"
                infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
                subnet_label = "vmotion"
                cluster_id = metalcloud_vmware_vcf.cluster01.cluster_id
                network_id = metalcloud_network.wan.network_id
                subnet_pool_id = data.metalcloud_subnet_pool.subnetpool2.subnet_pool_id
                subnet_automatic_allocation = false
                subnet_override_vlan_auto_allocation_index = 2
                subnet_override_vlan_id = 0
                subnet_is_ip_range = false
                subnet_prefix_size = 24
                
}


resource "metalcloud_subnet" "vsan" {
                subnet_type = "ipv4"
                infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
                subnet_label="vsan"
                cluster_id = metalcloud_vmware_vcf.cluster01.cluster_id
                network_id = metalcloud_network.wan.network_id
                subnet_pool_id = data.metalcloud_subnet_pool.subnetpool2.subnet_pool_id
                subnet_automatic_allocation = false
                subnet_override_vlan_auto_allocation_index = 3
                subnet_override_vlan_id = 0
                subnet_is_ip_range = false
                subnet_prefix_size = 24
                
}

resource "metalcloud_subnet" "nsx-host-overlay" {
                subnet_type = "ipv4"
                infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
                subnet_label="nsx-host-overlay"
                cluster_id = metalcloud_vmware_vcf.cluster01.cluster_id
                network_id = metalcloud_network.wan.network_id
                subnet_pool_id = data.metalcloud_subnet_pool.subnetpool2.subnet_pool_id
                subnet_automatic_allocation = false
                subnet_override_vlan_auto_allocation_index = 4
                subnet_override_vlan_id = 0
                subnet_is_ip_range = false
                subnet_prefix_size = 24
}

 
# Use this resource to effect deploys of the above resources.
resource "metalcloud_infrastructure_deployer" "infrastructure_deployer" {
 
  infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
 
  # Set this to false to actually trigger deploys.
  prevent_deploy = true
 
  #these options will make terraform apply operation will wait for the deploy to finish (when prevent_deploy is false)
  #instead of exiting while the deploy is ongoing
 
  await_deploy_finished = false
 
  #this option disables a safety check that MetalSoft performs to prevent accidental data loss
  #it is required when testing delete operations
 
  allow_data_loss = true
 
  # IMPORTANT. This is important to ensure that deploys happen after everything else. If you need to add or remove resources dynamically
  # use either count or for_each in the resources or move everything that is dynamic into a module and make this depend on the module
  depends_on = [
    metalcloud_network.wan,
    metalcloud_network.lan1,
    metalcloud_network.lan2,
    metalcloud_vmware_vcf.cluster01
  ]
}
 
data "metalcloud_infrastructure_output" "output"{
    infrastructure_id = data.metalcloud_infrastructure.infra.id
    depends_on = [ resource.metalcloud_infrastructure_deployer.infrastructure_deployer ]
}
output "cluster_credentials" {
    value = jsondecode(data.metalcloud_infrastructure_output.output.clusters)
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