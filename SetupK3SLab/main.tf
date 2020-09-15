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

resource "esxi_guest" "okd4_bootstrap" {
  guest_name     = "okd4_bootstrap"
  numvcpus       = "4"
  memsize        = "16384" # in Mb
  boot_disk_size = "120"   # in Gb
  boot_disk_type = "thin"
  disk_store     = var.datastore
  power          = "on"
  virthwver      = "13"
  clone_from_vm = "/Template-CentOS-8"
  guestinfo      = {
    metadata = "okd4_bootstrap"
  }

  network_interfaces {
    mac_address     = var.hn_to_okd4mac["okd4_bootstrap"]
    virtual_network = var.home_network
    nic_type        = "vmxnet3"
    # NOTE: the ipv4_address/_gateway are not supported with esxi.
    # Use the CloudInit or other options documented here:
    #   https://github.com/josenk/terraform-provider-esxi-wiki
  }
}

resource "esxi_guest" "okd4_services" {
  guest_name     = "okd4_services"
  numvcpus       = "4"
  memsize        = "4096" # in Mb
  boot_disk_size = "120"   # in Gb
  boot_disk_type = "thin"
  disk_store     = var.datastore
  power          = "on"
  virthwver      = "13"
  clone_from_vm = "/Template-CentOS-8"
  guestinfo      = {
    metadata = "okd4_services"
  }

  network_interfaces {
    mac_address     = var.hn_to_okd4mac["okd4_services"]
    virtual_network = var.home_network
    nic_type        = "vmxnet3"
    # NOTE: the ipv4_address/_gateway are not supported with esxi.
    # Use the CloudInit or other options documented here:
    #   https://github.com/josenk/terraform-provider-esxi-wiki
  }
}

resource "esxi_guest" "okd4_pfsense" {
  guest_name     = "okd4_pfsense"
  numvcpus       = "1"
  memsize        = "1024" # in Mb
  boot_disk_size = "8"   # in Gb
  boot_disk_type = "thin"
  disk_store     = var.datastore
  power          = "on"
  virthwver      = "13"
  clone_from_vm = "/Template-pfSense-2.4.5"
  guestinfo      = {
    metadata = "okd4_pfsense"
  }

  network_interfaces {
    mac_address     = var.hn_to_okd4mac["okd4_pfsense"]
    virtual_network = var.home_network
    nic_type        = "vmxnet3"
    # NOTE: the ipv4_address/_gateway are not supported with esxi.
    # Use the CloudInit or other options documented here:
    #   https://github.com/josenk/terraform-provider-esxi-wiki
  }
}

resource "esxi_guest" "okd4_control_plane" {
  guest_name     = "okd4_control_plane_${count.index}"
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
    mac_address     = var.hn_to_okd4mac["okd4_control_plane_${count.index}"]
  }
}

resource "esxi_guest" "okd4_compute" {
  guest_name     = "okd4_compute_${count.index}"
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
    mac_address     = var.hn_to_okd4mac["okd4_compute_${count.index}"]
  }
}

resource "local_file" "AnsibleInventory" {
 content = templatefile("hosts.tpl",
   {
    okd4_bootstrap-dns = esxi_guest.okd4_bootstrap.guest_name,
    okd4_bootstrap-ip  = esxi_guest.okd4_bootstrap.ip_address,
    okd4_bootstrap-id  = esxi_guest.okd4_bootstrap.id,
  
    okd4_services-dns = esxi_guest.okd4_services.guest_name,
    okd4_services-ip  = esxi_guest.okd4_services.ip_address,
    okd4_services-id  = esxi_guest.okd4_services.id,
  
    okd4_pfsense-dns = esxi_guest.okd4_pfsense.guest_name,
    okd4_pfsense-ip  = esxi_guest.okd4_pfsense.ip_address,
    okd4_pfsense-id  = esxi_guest.okd4_pfsense.id,
  
    okd4_control_plane-dns = esxi_guest.okd4_control_plane.*.guest_name,
    okd4_control_plane-ip  = esxi_guest.okd4_control_plane.*.ip_address,
    okd4_control_plane-id  = esxi_guest.okd4_control_plane.*.id
  
    okd4_compute-dns = esxi_guest.okd4_compute.*.guest_name,
    okd4_compute-ip  = esxi_guest.okd4_compute.*.ip_address,
    okd4_compute-id  = esxi_guest.okd4_compute.*.id
   }
 )
 filename = "inventory"
}
