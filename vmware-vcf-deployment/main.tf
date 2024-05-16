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

resource "metalcloud_subnet" "subnet01" {
                subnet_type = "ipv4"
                infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
                subnet_label="esxi_mgmt"
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


resource "metalcloud_subnet" "subnet02" {
                subnet_type = "ipv4"
                infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
                subnet_label="vmotion"
                cluster_id = metalcloud_vmware_vcf.cluster01.cluster_id
                network_id = metalcloud_network.wan.network_id
                subnet_pool_id = data.metalcloud_subnet_pool.subnetpool1.subnet_pool_id
                subnet_automatic_allocation = false
                subnet_override_vlan_auto_allocation_index = 2
                subnet_override_vlan_id = 0
                subnet_is_ip_range = false
                subnet_prefix_size = 24
                
}


resource "metalcloud_subnet" "subnet03" {
                subnet_type = "ipv4"
                infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
                subnet_label="vsan"
                cluster_id = metalcloud_vmware_vcf.cluster01.cluster_id
                network_id = metalcloud_network.wan.network_id
                subnet_pool_id = data.metalcloud_subnet_pool.subnetpool1.subnet_pool_id
                subnet_automatic_allocation = false
                subnet_override_vlan_auto_allocation_index = 3
                subnet_override_vlan_id = 0
                subnet_is_ip_range = false
                subnet_prefix_size = 24
                
}

resource "metalcloud_subnet" "subnet04" {
                subnet_type = "ipv4"
                infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
                subnet_label="nsx-host-overlay"
                cluster_id = metalcloud_vmware_vcf.cluster01.cluster_id
                network_id = metalcloud_network.wan.network_id
                subnet_pool_id = data.metalcloud_subnet_pool.subnetpool1.subnet_pool_id
                subnet_automatic_allocation = false
                subnet_override_vlan_auto_allocation_index = 4
                subnet_override_vlan_id = 0
                subnet_is_ip_range = false
                subnet_prefix_size = 24
}

/*
await bsidev.subnet_create(1908, {
    subnet_is_ip_range: true,
    subnet_ip_range_ip_count: 30,
    subnet_pool_id: 48,
    subnet_override_vlan_id: null,
    subnet_override_vlan_auto_allocation_index: 1,
    subnet_type: 'ipv4',
    subnet_automatic_allocation: false,
    subnet_prefix_size: 24,
    cluster_id: 1808
})

await bsidev.subnet_create(1908, {
    subnet_is_ip_range: false,
    subnet_pool_id: 53,
    subnet_override_vlan_id: null,
    subnet_override_vlan_auto_allocation_index: 2,
    subnet_type: 'ipv4',
    subnet_automatic_allocation: false,
    subnet_prefix_size: 24,
    cluster_id: 1808
})


await bsidev.subnet_create(1908, {
    subnet_is_ip_range: false,
    subnet_pool_id: 54,
    subnet_override_vlan_id: null,
    subnet_override_vlan_auto_allocation_index: 3,
    subnet_type: 'ipv4',
    subnet_automatic_allocation: false,
    subnet_prefix_size: 24,
    cluster_id: 1808
})


await bsidev.subnet_create(1908, {
    subnet_is_ip_range: false,
    subnet_pool_id: 55,
    subnet_override_vlan_id: null,
    subnet_override_vlan_auto_allocation_index: 4,
    subnet_type: 'ipv4',
    subnet_automatic_allocation: false,
    subnet_prefix_size: 24,
    cluster_id: 1808
})
*/


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