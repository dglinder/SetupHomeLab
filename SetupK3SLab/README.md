# Fixups for new nodes
sudo vi /etc/sysconfig/network-scripts/ifcfg-ens192
  IPADDR=192.168.65.XX
  BOOTPROTO=none
  GATEWAY=192.168.65.1
  DNS1=192.168.65.7
  DOMAIN=lab.linder.org

N=2
sudo hostnamectl set-hostname k3s_node${N}.lab.linder.org


[master]
192.168.65.75 # k3s_master

[node]
192.168.65.76 # k3s_node1
192.168.65.77 # k3s_node2
192.168.65.78 # k3s_node3
192.168.65.79 # k3s_node4

[k3s_cluster:children]
master
node
