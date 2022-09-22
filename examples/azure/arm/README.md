# Azure ARM Example

## Documentation

- https://www.packer.io/downloads
- https://www.packer.io/docs/terminology
- https://www.packer.io/docs/commands
- https://www.packer.io/docs/templates/hcl_templates
- https://www.packer.io/plugins/builders/azure
- https://www.packer.io/plugins/builders/azure/arm

## Install Packer

```bash
# Install
# https://www.packer.io/downloads
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install packer
```

## Prep

Create a target resource group for the managed image:

```bash
# login
az login

# select subscription
az account set --subscription 'MY_SUB_NAME'

# create resource group
az group create --name 'packer-images-rg' --location 'uksouth'
```

## Build Image

The example below build an Ubuntu image in Azure, using Azure CLI authentication:

```bash
# login
az login

# select subscription
az account set --subscription 'MY_SUB_NAME'

# move into example folder
cd examples/azure/arm/

# init
packer init ubuntu.pkr.hcl

# validate
packer validate .

# build (prompt for cleanup action on error)
# https://www.packer.io/docs/commands/build#ask
packer build -on-error=ask ubuntu.pkr.hcl
```
