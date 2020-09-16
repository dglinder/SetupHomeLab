# Setup okd4 lab VMs
# After this runs, use the inventory to setup with home lab script:
# ansible-playbook -i inventory ~/SetupHomeLab/main.yml -u root

terraform {
  required_version = ">= 0.13"
  required_providers {
    esxi = {
      source  = "registry.terraform.io/josenk/esxi"
      version = "~> 1.7.1"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}

# Define our variables here.  Set them in terraform.tfvars
variable "my_esxi_hostname" { type = string }
variable "my_esxi_username" { type = string }
variable "my_esxi_password" { type = string }
variable "my_esxi_hostport" {
  type = number
  default = 22
}
variable "my_esxi_hostssl" {
  type = string
  default = 443
}
variable "datastore" { type = string }
variable "vswitch" { type = string }
variable "vlan_id" { type = number }
variable "home_network" { type = string }
variable "okd4_network" { type = string }
variable "guest_vm_ssh_user" { type = string }
variable "guest_vm_ssh_port" { type = number }
variable "guest_vm_ssh_passwd" { type = string }
variable "hn_to_ip" { type = map }
variable "hn_to_okd4mac" { type = map }
variable "hn_to_homemac" { type = map }
variable "hn_to_nm" { type = map }
variable "hn_to_gw" { type = map }

provider "esxi" {
  esxi_hostname = var.my_esxi_hostname
  esxi_hostport = var.my_esxi_hostport
  esxi_hostssl  = var.my_esxi_hostssl
  esxi_username = var.my_esxi_username
  esxi_password = var.my_esxi_password
}

resource "esxi_guest" "okd4-bootstrap" {
  guest_name     = "okd4-bootstrap"
  numvcpus       = "4"
  memsize        = "16384" # in Mb
  boot_disk_size = "120"   # in Gb
  boot_disk_type = "thin"
  disk_store     = var.datastore
  power          = "on"
  virthwver      = "13"
  clone_from_vm = "/Template-CentOS-8"
  guestinfo      = {
    metadata = "okd4-bootstrap"
  }

  network_interfaces {
    mac_address     = var.hn_to_okd4mac["okd4-bootstrap"]
    virtual_network = var.home_network
    nic_type        = "vmxnet3"
    # NOTE: the ipv4_address/_gateway are not supported with esxi.
    # Use the CloudInit or other options documented here:
    #   https://github.com/josenk/terraform-provider-esxi-wiki
  }
}

resource "esxi_guest" "okd4-services" {
  guest_name     = "okd4-services"
  numvcpus       = "4"
  memsize        = "4096" # in Mb
  boot_disk_size = "120"   # in Gb
  boot_disk_type = "thin"
  disk_store     = var.datastore
  power          = "on"
  virthwver      = "13"
  clone_from_vm = "/Template-CentOS-8"
  guestinfo      = {
    metadata = "okd4-services"
  }

  network_interfaces {
    mac_address     = var.hn_to_okd4mac["okd4-services"]
    virtual_network = var.home_network
    nic_type        = "vmxnet3"
    # NOTE: the ipv4_address/_gateway are not supported with esxi.
    # Use the CloudInit or other options documented here:
    #   https://github.com/josenk/terraform-provider-esxi-wiki
  }
}

resource "esxi_guest" "okd4-pfsense" {
  guest_name     = "okd4-pfsense"
  numvcpus       = "1"
  memsize        = "1024" # in Mb
  boot_disk_size = "8"   # in Gb
  boot_disk_type = "thin"
  disk_store     = var.datastore
  power          = "on"
  virthwver      = "13"
  clone_from_vm = "/Template-pfSense-2.4.5"
  guestinfo      = {
    metadata = "okd4-pfsense"
  }

  network_interfaces {
    mac_address     = var.hn_to_okd4mac["okd4-pfsense"]
    virtual_network = var.home_network
    nic_type        = "vmxnet3"
    # NOTE: the ipv4_address/_gateway are not supported with esxi.
    # Use the CloudInit or other options documented here:
    #   https://github.com/josenk/terraform-provider-esxi-wiki
  }
}

resource "esxi_guest" "okd4-control-plane" {
  guest_name     = "okd4-control-plane-${count.index}"
  numvcpus       = "4"
  memsize        = "16384" # in Mb
  boot_disk_size = "120"   # in Gb
  boot_disk_type = "thin"
  disk_store     = var.datastore
  power          = "on"
  virthwver      = "13"
  clone_from_vm = "/Template-CentOS-8"
  count          = 3

  network_interfaces {
    virtual_network = var.home_network
    nic_type        = "vmxnet3"
    mac_address     = var.hn_to_okd4mac["okd4-control-plane-${count.index}"]
  }
}

resource "esxi_guest" "okd4-compute" {
  guest_name     = "okd4-compute-${count.index}"
  numvcpus       = "4"
  memsize        = "16384" # in Mb
  boot_disk_size = "120"   # in Gb
  boot_disk_type = "thin"
  disk_store     = var.datastore
  power          = "on"
  virthwver      = "13"
  clone_from_vm = "/Template-CentOS-8"
  count          = 2

  network_interfaces {
    virtual_network = var.home_network
    nic_type        = "vmxnet3"
    mac_address     = var.hn_to_okd4mac["okd4-compute-${count.index}"]
  }
}

resource "local_file" "AnsibleInventory" {
 content = templatefile("hosts.tpl",
   {
    okd4-bootstrap-dns = esxi_guest.okd4-bootstrap.guest_name,
    okd4-bootstrap-ip  = esxi_guest.okd4-bootstrap.ip_address,
    okd4-bootstrap-id  = esxi_guest.okd4-bootstrap.id,
  
    okd4-services-dns = esxi_guest.okd4-services.guest_name,
    okd4-services-ip  = esxi_guest.okd4-services.ip_address,
    okd4-services-id  = esxi_guest.okd4-services.id,
  
    okd4-pfsense-dns = esxi_guest.okd4-pfsense.guest_name,
    okd4-pfsense-ip  = esxi_guest.okd4-pfsense.ip_address,
    okd4-pfsense-id  = esxi_guest.okd4-pfsense.id,
  
    okd4-control-plane-dns = esxi_guest.okd4-control-plane.*.guest_name,
    okd4-control-plane-ip  = esxi_guest.okd4-control-plane.*.ip_address,
    okd4-control-plane-id  = esxi_guest.okd4-control-plane.*.id
  
    okd4-compute-dns = esxi_guest.okd4-compute.*.guest_name,
    okd4-compute-ip  = esxi_guest.okd4-compute.*.ip_address,
    okd4-compute-id  = esxi_guest.okd4-compute.*.id
   }
 )
 filename = "inventory"
}
