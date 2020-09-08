my_esxi_hostname = "esx.lab.linder.org"
my_esxi_username = "root"
my_esxi_password = "1234NewS!@#$"

datastore = "datastore1" 
vlan_id = 20
vswitch = "vSwitch0"
home_network = "VM Network"
k3s_network = "OKD"

guest_vm_ssh_user = "root"
guest_vm_ssh_port = 22
guest_vm_ssh_passwd = "123NewS!@#"

hn_to_ip = {
    k3s_master    = "192.168.1.200"
    k3s_compute-0 = "192.168.1.204"
    k3s_compute-1 = "192.168.1.205"
    k3s_compute-2 = "192.168.1.206"
}

hn_to_k3smac = {
    k3s_master    = "00:50:56:01:01:00"
    k3s_compute-0 = "00:50:56:01:01:04"
    k3s_compute-1 = "00:50:56:01:01:05"
    k3s_compute-2 = "00:50:56:01:01:06"
}

hn_to_homemac = {
    k3s_master = "00:50:56:01:02:00"
}

hn_to_nm = {
    k3s_master    = "24"
    k3s_compute-0 = "24"
    k3s_compute-1 = "24"
    k3s_compute-2 = "24"
}

hn_to_gw = {
    k3s_master    = "192.168.1.1"
    k3s_compute-0 = "192.168.1.1"
    k3s_compute-1 = "192.168.1.1"
    k3s_compute-2 = "192.168.1.1"
}
