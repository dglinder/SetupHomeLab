Setup notes:

1. Attach a subscription
   * `subscription-manager register`
   * `subscription-manager attach --auto`
1. Add the Ansible repository
From: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-rhel-centos-or-fedora
   * `subscription-manager repos --enable rhel-7-server-ansible-2.9-rpms`
1. Install Ansible and Ansible Galaxy
   * `yum -y install ansible ansible-galaxy`
1. Ensure the roles are downloaded using the requirements.yml:
   * `ansible-galaxy role install -r roles/requirements.yml -p ./roles/`
1. Make sure your account on each inventory has this users ssh key
   * `ssh-copy-id -i ~/.ssh/id_ed25519.pub ${USER}@[target]`
1. Add/update the sudo password in the password.yml file
   * ansible-vault create password.yml
     * Enter new vault password for this file
     * This will be stored in "vault_password" file later
   * ansible-vault edit password.yml
     * Enter the vault password used for this file
     * Add and/or correct the "" variable.
   * ansible_become_password: "MyPasswordHere"
1. Store that vault password in the "vault_password" file
   * NOTE: Do NOT check this file into a repo
1. Then run like this:
   * ./main.yml -i inventory.ini --extra-vars '@password.yml' --vault-password-file=vault_password
