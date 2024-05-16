terraform {
  required_providers {
    metalcloud = {
      source = "metalsoft-io/metalcloud"
       version = ">= 2.5.9"
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


data "metalcloud_infrastructure" "infra" {
   
		infrastructure_label = "infra-test-eks"
		datacenter_name = "${var.datacenter}" 
	 
		create_if_not_exists = true
}
	
data "metalcloud_server_type" "large"{
		server_type_name = "M.96.768.5.v5"
}
	
resource "metalcloud_network" "wan" {
	infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
	network_type = "wan"
}
/*
resource "metalcloud_network" "san" {
	infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
	network_type = "san"
}
*/
	
data "metalcloud_network_profile" "eksa-mgmt"{
	network_profile_label = "eksa-mgmt"
	datacenter_name = "${var.datacenter}" 
}
	

data "metalcloud_network_profile" "eksa-control-plane"{
	network_profile_label = "eksa-control-plane"
	datacenter_name = "${var.datacenter}" 
}

data "metalcloud_network_profile" "eksa-workload"{
	network_profile_label = "eksa-workload"
	datacenter_name = "${var.datacenter}" 
}

resource "metalcloud_eksa" "cluster01" {
	infrastructure_id =  data.metalcloud_infrastructure.infra.infrastructure_id
	
	cluster_label = "test-eksa"

	
	instance_array_instance_count_eksa_mgmt = 1
	instance_array_instance_count_mgmt = 1
	instance_array_instance_count_worker = 1
	
	instance_server_type_eksa_mgmt {
		instance_index = 0
		server_type_id = data.metalcloud_server_type.large.server_type_id
	}
	
	instance_server_type_mgmt {
		instance_index = 0
		server_type_id = data.metalcloud_server_type.large.server_type_id
	}
	
	instance_server_type_worker {
		instance_index = 0
		server_type_id = data.metalcloud_server_type.large.server_type_id
	}
	
	
	interface_eksa_mgmt{
		interface_index = 0
		network_id = metalcloud_network.wan.id
	}
	/*
	interface_eksa_mgmt{
		interface_index = 1
		network_id = metalcloud_network.san.id
	}
	*/
	
	interface_mgmt{
		interface_index = 0
		network_id = metalcloud_network.wan.id
	}
	/*
	interface_mgmt {
		interface_index = 1
		network_id = metalcloud_network.san.id
	}
	*/
	interface_worker {
		interface_index = 0
		network_id = metalcloud_network.wan.id
	}
	
	/*
	interface_worker {
		interface_index = 1
		network_id = metalcloud_network.san.id
	}
	*/
	instance_array_network_profile_eksa_mgmt {
		network_id = metalcloud_network.wan.id
		network_profile_id = data.metalcloud_network_profile.eksa-mgmt.id
	}

	instance_array_network_profile_mgmt {
		network_id = metalcloud_network.wan.id
		network_profile_id = data.metalcloud_network_profile.eksa-control-plane.id
	}

	instance_array_network_profile_worker {
		network_id = metalcloud_network.wan.id
		network_profile_id = data.metalcloud_network_profile.eksa-workload.id
	}
}

data "metalcloud_subnet_pool" "wan" {
	subnet_pool_label = "wan"
}

resource "metalcloud_subnet" "kube_boot_network" {
		subnet_type = "ipv4"
		infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
		subnet_label="kube-boot-network"
		cluster_id = metalcloud_eksa.cluster01.cluster_id
		network_id = metalcloud_network.wan.network_id
		subnet_pool_id = data.metalcloud_subnet_pool.wan.subnet_pool_id
		subnet_automatic_allocation = false
		subnet_is_ip_range = true
		subnet_ip_range_ip_count = 5
		subnet_override_vlan_id=1003
}



resource "metalcloud_subnet" "kube_vip_network" {
		subnet_type = "ipv4"
		subnet_label="kube-vip-network"
		infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
		cluster_id = metalcloud_eksa.cluster01.cluster_id
		network_id = metalcloud_network.wan.network_id
		subnet_pool_id = data.metalcloud_subnet_pool.wan.subnet_pool_id
		subnet_automatic_allocation = false
		subnet_is_ip_range = true
		subnet_ip_range_ip_count = 5
		subnet_override_vlan_id=1003
		
}


resource "metalcloud_subnet" "kube_services_load_balancer_network" {
		subnet_type = "ipv4"
		subnet_label="kube-services-lb-network"
		infrastructure_id = data.metalcloud_infrastructure.infra.infrastructure_id
		cluster_id = metalcloud_eksa.cluster01.cluster_id
		network_id = metalcloud_network.wan.network_id
		subnet_pool_id = data.metalcloud_subnet_pool.wan.subnet_pool_id
		subnet_automatic_allocation = false
		subnet_is_ip_range = true
		subnet_ip_range_ip_count = 5
		subnet_override_vlan_id=1003
		
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
   metalcloud_eksa.cluster01,
   metalcloud_subnet.kube_boot_network,
   metalcloud_subnet.kube_vip_network,
   metalcloud_subnet.kube_services_load_balancer_network,
  ]
}

data "metalcloud_infrastructure_output" "output"{
    infrastructure_id = data.metalcloud_infrastructure.infra.id
    depends_on = [ resource.metalcloud_infrastructure_deployer.infrastructure_deployer ]
}

output "credentials" {
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