#cloud-config
users:
  - name: ${user}
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - ${ssh_key}
      - ${ssh_key_ext}