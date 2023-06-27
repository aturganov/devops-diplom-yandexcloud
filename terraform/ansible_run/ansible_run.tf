resource "null_resource" "get-vk8s-config" {
  provisioner "local-exec" {
    command = "ansible-playbook -i ./.ansible/inventory.ini k8s_config.yaml"
  }

#   depends_on = [
#     local_file.ansible-inventory,
#   ]
}