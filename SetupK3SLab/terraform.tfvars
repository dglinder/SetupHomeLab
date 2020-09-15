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
    okd4_bootstrap       = "192.168.1.200"
    okd4_services        = "192.168.1.210"
    okd4_pfsense         = "192.168.1.1"
    okd4_control_plane_0 = "192.168.1.201"
    okd4_control_plane_1 = "192.168.1.202"
    okd4_control_plane_2 = "192.168.1.203"
    okd4_compute_0       = "192.168.1.204"
    okd4_compute_1       = "192.168.1.205"
}

hn_to_okd4mac = {
    okd4_bootstrap       = "00:50:56:01:01:00"
    okd4_services        = "00:50:56:01:01:10"
    okd4_pfsense         = "00:50:56:01:01:11"
    okd4_control_plane_0 = "00:50:56:01:01:01"
    okd4_control_plane_1 = "00:50:56:01:01:02"
    okd4_control_plane_2 = "00:50:56:01:01:03"
    okd4_compute_0       = "00:50:56:01:01:04"
    okd4_compute_1       = "00:50:56:01:01:05"
}

hn_to_homemac = {
    okd4_bootstrap = "00:50:56:01:02:00"
    okd4_pfsense   = "00:50:56:01:02:11"
}

hn_to_nm = {
    okd4_bootstrap       = "24"
    okd4_services        = "24"
    okd4_pfsense         = "24"
    okd4_control_plane_0 = "24"
    okd4_control_plane_1 = "24"
    okd4_control_plane_2 = "24"
    okd4_compute_0       = "24"
    okd4_compute_1       = "24"
}

hn_to_gw = {
    okd4_bootstrap       = "192.168.1.1"
    okd4_services        = "192.168.1.1"
    okd4_pfsense         = "192.168.65.1"
    okd4_control_plane_0 = "192.168.1.1"
    okd4_control_plane_1 = "192.168.1.1"
    okd4_control_plane_2 = "192.168.1.1"
    okd4_compute_0       = "192.168.1.1"
    okd4_compute_1       = "192.168.1.1"
}
