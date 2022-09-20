packer {
  required_plugins {
    azure = {
      version = ">= 1.3.1"
      source  = "github.com/hashicorp/azure"
    }
  }
}

source "azure-arm" "example" {
  location = "uksouth"
  vm_size  = "Standard_DS2_v2"

  # authentication options
  # use_interactive_auth = true
  use_azure_cli_auth = true

  # source image options
  # az vm image list-skus --location uksouth --publisher Canonical --offer UbuntuServer --output table
  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "UbuntuServer"
  image_sku       = "18.04-LTS"

  azure_tags = {
    author = "Adam Rush"
    dept   = "devops"
    source = "packer"
  }

  # save to managed image options
  managed_image_resource_group_name = "packer-images-rg"
  managed_image_name                = "ubuntu-nginx"

  # save to vhd options
  # storage_account        = "virtualmachines"
  # capture_container_name = "images"
  # capture_name_prefix    = "packer"
}

build {
  sources = ["source.azure-arm.example"]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "apt-get update",
      "apt-get upgrade -y",
      "apt-get -y install nginx",
      "echo Running deprovisioning step...",
      "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
    ]
    inline_shebang = "/bin/sh -x"
  }
}
