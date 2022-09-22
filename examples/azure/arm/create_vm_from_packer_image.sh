#!/bin/bash
# create vm from custom virtual machine image

# vars
image_resource_group_name="packer-images-rg"
image_name="ubuntu-nginx"
image_id=$(az image show --resource-group "$image_resource_group_name" --name "$image_name" --query "id" --output tsv)
location="uksouth"
vm_resource_group_name="packer-vms-rg"
vm1_name="linux01"
vm2_name="linux02"
public_ssh_key_path="$HOME/.ssh/id_rsa.pub"

# login
az login

# select subscription
az account set --subscription 'MY_SUB_NAME'
az account show

# [optional] create ssh key
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# create resource group
az group create --name "$vm_resource_group_name" --location "$location"

# create vms
# https://docs.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az-vm-create
az vm create \
    --resource-group $vm_resource_group_name \
    --name $vm1_name \
    --image "$image_id" \
    --admin-username sysadmin \
    --ssh-key-values "$public_ssh_key_path" \
    --no-wait

az vm create \
    --resource-group $vm_resource_group_name \
    --name $vm2_name \
    --image "$image_id" \
    --admin-username sysadmin \
    --ssh-key-values "$public_ssh_key_path"

# open port
az vm open-port \
    --resource-group $vm_resource_group_name \
    --name $vm1_name \
    --port 80

# get public IP address
vm1_ip=$(az vm list-ip-addresses --resource-group $vm_resource_group_name --name $vm1_name --query [].virtualMachine.network.publicIpAddresses[].ipAddress -o tsv)
vm2_ip=$(az vm list-ip-addresses --resource-group $vm_resource_group_name --name $vm2_name --query [].virtualMachine.network.publicIpAddresses[].ipAddress -o tsv)

# test web servers
curl -v "$vm1_ip" --port 80
curl -v "$vm2_ip"

# test direct connectivity using netcat
# connect to vm1
ssh "sysadmin@$vm1_ip"

# start netcat listener on port 80
sudo nc -l 80

# from a second console session, send test message from vm2 to vm1
ssh "sysadmin@$vm2_ip" echo "Connectivity works between [$vm1_ip] and [$vm2_ip]" | nc "$vm1_ip" 80

# CLEANUP
echo "Deleting VM Resource Group [$vm_resource_group_name] ..."
az group delete --name "$vm_resource_group_name"
