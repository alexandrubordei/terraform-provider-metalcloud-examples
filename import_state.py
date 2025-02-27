#!python3

import os
import sys
import requests
import logging
import json
import subprocess

logging.basicConfig(level=logging.INFO)


METALCLOUD_API_KEY = os.getenv("METALCLOUD_API_KEY")
if METALCLOUD_API_KEY==None:
    raise Exception("METALCLOUD_API_KEY environment key not set") 

ENV_URL=os.getenv("METALCLOUD_ENDPOINT","https://us10.metalsoft.io")+"api/developer/developer"

AUTH_HEADER="Bearer "+METALCLOUD_API_KEY
USER_ID= METALCLOUD_API_KEY.split(":")[0]
INFRA_LABEL=sys.argv[1]

logging.info(f"User id is {USER_ID}")

if len(sys.argv)==1:
    raise Exception("Syntax: "+sys.argv[0]+" <infrastructure_label>")

def call(method, params=[]):
    r=requests.post(ENV_URL, headers={"Authorization":AUTH_HEADER}, json={"id":1,"jsonrpc":2.0, "method":method,"params":params})
    if os.getenv("METALCLOUD_LOGGING_ENABLED")=="true":
        logging.debug(json.dumps(r.json(),indent=4))
    return r.json()["result"]


#get the infrastructure id
infras = call("infrastructures", [USER_ID])

infra_id=0
for key,infra in infras.items():
    if infra['infrastructure_label']==INFRA_LABEL:
        infra_id=infra["infrastructure_id"]

if infra_id==0:
    raise Exception(f"Infrastructure with label {INFRA_LABEL} not found")

logging.info(f"Infrastructure ID is {infra_id}")


#get the cluster id
clusters = call("clusters", [infra_id])

cluster_id=0
for key,val in clusters.items():
    if val['cluster_type']=="vmware_vsphere":
        cluster_id=val["cluster_id"]

if cluster_id==0:
    raise Exception(f"Cluster of type vmware_vsphere not found")

logging.info(f"Cluster ID is {cluster_id}")



#get the network ids
networks = call("networks", [infra_id])

network_ids=[]
idx=0
for key,val in networks.items():

    #note that this is specific to the manifest it needs to match the way the networks are named
    if val["network_type"]=="wan":
        network_name="wan"
    else:
        idx+=1
        network_name=f"lan{idx}"
        
    
    network_ids.append({
        "network_type": val["network_type"],
        "network_id": val["network_id"],
        "network_name": network_name
        })


#note that this is specific to the manifest it needs to match the count of networks in the manifest
if len(network_ids)!=4:
    raise Exception(f"Could not determine the IDs of the 4 networks")

logging.info(f"Network IDs are: {json.dumps(network_ids)}")

def terraform_import(resource,id):
    return subprocess.Popen(f"terraform import {resource} {id}", shell=True, stdout=subprocess.PIPE).stdout.read()

#backup the state files
if os.path.exists("terraform.tfstate.import-backup"):
    os.remove("terraform.tfstate.import-backup")

if os.path.exists("terraform.tfstate"):
    os.rename("terraform.tfstate", "terraform.tfstate.import-backup")

#this is manifest specific
terraform_import("metalcloud_infrastructure_deployer.infrastructure_deployer", infra_id)
terraform_import("metalcloud_vmware_vsphere.VMWareVsphere", cluster_id)

for network in network_ids:
        terraform_import(f"metalcloud_network.{network['network_name']}", network["network_id"])
    