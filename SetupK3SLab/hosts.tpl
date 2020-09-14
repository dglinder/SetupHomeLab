[bootstrap]
${okd4_bootstrap-dns} ansible_host=${okd4_bootstrap-ip} # ${okd4_bootstrap-id}

[services]
${okd4_services-dns} ansible_host=${okd4_services-ip} # ${okd4_services-id}

[pfsense]
${okd4_pfsense-dns} ansible_host=${okd4_pfsense-ip} # ${okd4_pfsense-id}

[control_plane]
%{ for index, dns in okd4_control_plane-dns ~}
${dns} ansible_host=${okd4_control_plane-ip[index]} # ${okd4_control_plane-id[index]}
%{ endfor ~}

[compute]
%{ for index, dns in okd4_compute-dns ~}
${dns} ansible_host=${okd4_compute-ip[index]} # ${okd4_compute-id[index]}
%{ endfor ~}

[base_hosts:children]
bootstrap
control_plane
compute
services
pfsense
