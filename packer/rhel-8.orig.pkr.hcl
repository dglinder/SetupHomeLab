# Run like this:
# $ packer init rhel-8.pkr.hcl
# $ packer build rhel-8.pkr.hcl
# Get the pre-requisite plugins
packer {
  required_plugins {
    proxmox = {
      version = ">= 1.0.6"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "iso_checksum" {
  type    = string
  default = "sha256:8cb0dfacc94b789933253d5583a2fb7afce26d38d75be7c204975fe20b7bdf71"
}

variable "iso_url" {
  type    = string
  default = "synology-nfs-storage/isos/RedHat/rhel-8.6-x86_64-dvd.iso"
}

variable "pve_password" {
  type    = string
  default = "C@E$jh82#VdEVmf*R%V9Y!56"
}

variable "pve_token_ID" {
  type    = string
  default = "root@pam!anssrv-packer"
}

variable "pve_token_Secret" {
  type    = string
  default = "c5109ede-0f7c-413e-9c69-154bef1dbbf1"
}

variable "pve_username" {
  type    = string
  default = "root"
}

variable "rhel_password" {
  type    = string
  default = "packer"
}

variable "rhel_user" {
  type    = string
  default = "root"
}
# The "legacy_isotime" function has been provided for backwards compatability, but we recommend switching to the timestamp and formatdate functions.

source "proxmox-iso" "autogenerated_1" {
  boot_command = ["<up><tab> ip=dhcp inst.cmdline inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/RHEL8-ks.cfg<enter>"]
  boot_wait    = "30m"
  cores        = "2"
  cpu_type     = "kvm64"
  disks {
    cache_mode        = "none"
    disk_size         = "50G"
    format            = "qcow2"
    storage_pool      = "synology-nfs-storage"
    type              = "scsi"
  }
#  efi_config {
#    efi_storage_pool  = "synology-nfs-storage"
#    efi_type          = "4m"
#    pre_enrolled_keys = true
#  }
  http_directory           = "http"
  insecure_skip_tls_verify = "true"
  iso_checksum             = "${var.iso_checksum}"
  iso_storage_pool         = "synology-nfs-storage"
  iso_url                  = "${var.iso_url}"
  memory                   = "8192"
  network_adapters {
    bridge = "vmbr0"
    model  = "e1000"
  }
  node                 = "node-rhel-8"
  os                   = "l26"
  pool                 = "packer_pool"
  proxmox_url          = "https://pve1.lab.linder.org:8006/api2/json"
  scsi_controller      = "lsi"
  sockets              = "1"
  ssh_password         = "packer"
  ssh_timeout          = "30m"
  ssh_username         = "root"
#  template_description = "Red Hat Enterprise Linux 8, generated on ${legacy_isotime("2006-01-02T15:04:05Z")}"
  template_name        = "template-rhel-8-packer-26a"
  token                = "${var.pve_token_Secret}"
  unmount_iso          = true
  username             = "${var.pve_token_ID}"
  vm_id                = "555"
  vm_name              = "template-rhel-8.lab.linder.org"
}

build {
  sources = ["source.proxmox-iso.autogenerated_1"]
}
