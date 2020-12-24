my_esxi_hostname = "esx.lab.linder.org"
my_esxi_username = "root"
my_esxi_password = "1234NewS!@#$"

datastore = "datastore1" 
vlan_id = 20
vswitch = "vSwitch0"
home_network = "VM Network"
okd4_network = "OKD"

guest_vm_ssh_user = "root"
guest_vm_ssh_port = 22
guest_vm_ssh_passwd = "123NewS!@#"

hn_to_ip = {
    okd4-bootstrap       = "192.168.1.200"
    okd4-services        = "192.168.1.210"
    okd4-pfsense         = "192.168.1.1"
    okd4-control-plane-0 = "192.168.1.201"
    okd4-control-plane-1 = "192.168.1.202"
    okd4-control-plane-2 = "192.168.1.203"
    okd4-compute-0       = "192.168.1.204"
    okd4-compute-1       = "192.168.1.205"
}

hn_to_okd4mac = {
    okd4-bootstrap       = "00:50:56:01:01:00"
    okd4-services        = "00:50:56:01:01:10"
    okd4-pfsense         = "00:50:56:01:01:11"
    okd4-control-plane-0 = "00:50:56:01:01:01"
    okd4-control-plane-1 = "00:50:56:01:01:02"
    okd4-control-plane-2 = "00:50:56:01:01:03"
    okd4-compute-0       = "00:50:56:01:01:04"
    okd4-compute-1       = "00:50:56:01:01:05"
}

hn_to_homemac = {
    okd4-bootstrap = "00:50:56:01:02:00"
    okd4-pfsense   = "00:50:56:01:02:11"
}

hn_to_nm = {
    okd4-bootstrap       = "24"
    okd4-services        = "24"
    okd4-pfsense         = "24"
    okd4-control-plane-0 = "24"
    okd4-control-plane-1 = "24"
    okd4-control-plane-2 = "24"
    okd4-compute-0       = "24"
    okd4-compute-1       = "24"
}

hn_to_gw = {
    okd4-bootstrap       = "192.168.1.1"
    okd4-services        = "192.168.1.1"
    okd4-pfsense         = "192.168.65.1"
    okd4-control-plane-0 = "192.168.1.1"
    okd4-control-plane-1 = "192.168.1.1"
    okd4-control-plane-2 = "192.168.1.1"
    okd4-compute-0       = "192.168.1.1"
    okd4-compute-1       = "192.168.1.1"
}
