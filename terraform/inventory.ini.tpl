[all:vars]
ansible_user = "${ssh_user}"
ansible_ssh_private_key_file = "${private_key_path}"
ansible_python_interpreter = auto_silent

[app_hosts]
${app_ip_address} ansible_host=${app_ip_address}