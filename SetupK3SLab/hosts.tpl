[master]
${k3s_master-dns} ansible_host=${k3s_master-ip} # ${k3s_master-id}

[node]
%{ for index, dns in k3s_compute-dns ~}
${dns} ansible_host=${k3s_compute-ip[index]} # ${k3s_compute-id[index]}
%{ endfor ~}

[base_hosts:children]
master
node
