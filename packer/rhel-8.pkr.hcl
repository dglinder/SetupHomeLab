# STATE: Boots ISO, nothing else.
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

source "proxmox-iso" "rhel8-template" {
  proxmox_url = "https://pve1.lab.linder.org:8006/api2/json"
  insecure_skip_tls_verify = true
  username = "root@pam"
  password = "q7-19ezx"
  #token = "c5109ede-0f7c-41#3e-9c69-154bef1dbbf1"
  node = "pve2" #"pve1.lab.linder.org"
  iso_file = "synology-nfs-storage:iso/rhel-8.6-x86_64-dvd.iso"
  #iso_url = ""
  #iso_storage_pool         = "synology-nfs-storage"
  #iso_url                  = "${var.iso_url}"
  ssh_username         = "root"
  ssh_password         = "packer"
  
  #boot_command = ["<up><tab> ip=dhcp inst.cmdline inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/RHEL8-ks.cfg<wait10><enter>"]
#  iso_storage_pool         = "synology-nfs-storage"
#  cd_directory  = "http"
#  cd_files      = [ "./http/*" ]
#  cd_label      = "cddata"
  http_directory = "http"
  boot_command = [
    "<esc><wait>",
    "vmlinuz ",
    " initrd=initrd.img ",
#    " inst.stage2=hd:LABEL={{ user `ISO_LABEL`}} ",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/RHEL8-ks.cfg ",
#    " inst.ks=cdrom:CDLABEL=cddata:RHEL8-ks.cfg ",
    " <wait10> ",
    " <enter> "
  ]
  boot_wait    = "15s"  # Need more, but 30 seconds is good for early testing
  ssh_timeout  = "90s" # Need more, but 30 seconds is good for early testing
  cores        = "2"
  cpu_type     = "kvm64"
  memory                   = "8192"
  os                   = "l26"
  disks {
    cache_mode        = "none"
    disk_size         = "50G"
    format            = "qcow2"
    storage_pool      = "synology-nfs-storage"
    type              = "scsi"
  }
##  efi_config {
##    efi_storage_pool  = "synology-nfs-storage"
##    efi_type          = "4m"
##    pre_enrolled_keys = true
##  }
#  iso_checksum             = "${var.iso_checksum}"
#  iso_url                  = "${var.iso_url}"
#  network_adapters {
#    bridge = "vmbr0"
#    model  = "e1000"
#  }
#  pool                 = "packer_pool"
#  proxmox_url          = "https://pve1.lab.linder.org:8006/api2/json"
#  scsi_controller      = "lsi"
#  sockets              = "1"
#  ssh_password         = "packer"
#  ssh_username         = "root"
##  template_description = "Red Hat Enterprise Linux 8, generated on ${legacy_isotime("2006-01-02T15:04:05Z")}"
#  template_name        = "template-rhel-8-packer-26a"
#  token                = "${var.pve_token_Secret}"
#  unmount_iso          = true
#  username             = "${var.pve_token_ID}"
#  vm_id                = "555"
#  vm_name              = "template-rhel-8.lab.linder.org"
}

build {
  sources = ["source.proxmox-iso.rhel8-template"]
}
