# Setup K3S lab VMs
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
variable "k3s_network" { type = string }
variable "guest_vm_ssh_user" { type = string }
variable "guest_vm_ssh_port" { type = number }
variable "guest_vm_ssh_passwd" { type = string }
variable "hn_to_ip" { type = map }
variable "hn_to_k3smac" { type = map }
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

resource "esxi_guest" "k3s_master" {
  guest_name     = "k3s_master"
  numvcpus       = "4"
  memsize        = "16384" # in Mb
  boot_disk_size = "120"   # in Gb
  boot_disk_type = "thin"
  disk_store     = var.datastore
  power          = "on"
  virthwver      = "13"
  clone_from_vm = "/Template-CentOS-8"
  guestinfo      = {
    metadata = "k3s_master"
  }

  network_interfaces {
    mac_address     = var.hn_to_k3smac["k3s_master"]
    virtual_network = var.home_network
    nic_type        = "vmxnet3"
    # NOTE: the ipv4_address/_gateway are not supported with esxi.
    # Use the CloudInit or other options documented here:
    #   https://github.com/josenk/terraform-provider-esxi-wiki
  }
}

resource "esxi_guest" "k3s_compute" {
  guest_name     = "k3s_compute-${count.index}"
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
    mac_address     = var.hn_to_k3smac["k3s_compute-${count.index}"]
  }
}

resource "local_file" "AnsibleInventory" {
 content = templatefile("hosts.tpl",
   {
    k3s_master-dns = esxi_guest.k3s_master.guest_name,
    k3s_master-ip  = esxi_guest.k3s_master.ip_address,
    k3s_master-id  = esxi_guest.k3s_master.id,
  
    k3s_compute-dns = esxi_guest.k3s_compute.*.guest_name,
    k3s_compute-ip  = esxi_guest.k3s_compute.*.ip_address,
    k3s_compute-id  = esxi_guest.k3s_compute.*.id
   }
 )
 filename = "inventory"
}
