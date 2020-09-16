[bootstrap]
${okd4-bootstrap-dns} ansible_host=${okd4-bootstrap-ip} # ${okd4-bootstrap-id}

[services]
${okd4-services-dns} ansible_host=${okd4-services-ip} # ${okd4-services-id}

[pfsense]
${okd4-pfsense-dns} ansible_host=${okd4-pfsense-ip} # ${okd4-pfsense-id}

[control_plane]
%{ for index, dns in okd4-control-plane-dns ~}
${dns} ansible_host=${okd4-control-plane-ip[index]} # ${okd4-control-plane-id[index]}
%{ endfor ~}

[compute]
%{ for index, dns in okd4-compute-dns ~}
${dns} ansible_host=${okd4-compute-ip[index]} # ${okd4-compute-id[index]}
%{ endfor ~}

[base_hosts:children]
bootstrap
control_plane
compute
services
pfsense
