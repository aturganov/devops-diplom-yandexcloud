# https://internet-lab.ru/k8s_kubespray
resource "local_file" "k8s-kubespray" {
  content = <<-DOC
 
    [all]
    node1 ansible_host=${yandex_compute_instance.vm_stage_master.network_interface.0.ip_address} ip=${yandex_compute_instance.vm_stage_master.network_interface.0.ip_address}
    node2 ansible_host=${yandex_compute_instance.vm_stage_workers.0.network_interface.0.ip_address} ip=${yandex_compute_instance.vm_stage_workers.0.network_interface.0.ip_address}
    node3 ansible_host=${yandex_compute_instance.vm_stage_workers.1.network_interface.0.ip_address} ip=${yandex_compute_instance.vm_stage_workers.1.network_interface.0.ip_address}

    [kube_control_plane]
    node1

    [etcd]
    node1

    [kube_node]
    node2
    node3

    [calico_rr]

    [k8s_cluster:children]
    kube_control_plane
    kube_node
    calico_rr

    DOC
  filename = "./.kubespray/inventory.ini"

  depends_on = [
    yandex_compute_instance.vm_stage_master,
    yandex_compute_instance.vm_stage_workers
  ]
}

# --ssh-common-args='-o StrictHostKeyChecking=no'
resource "null_resource" "pre_kubespray" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ./.ansible/inventory.ini kubespray.yaml -e ansible_become_password=Temp001 --extra-vars external_ip=${yandex_compute_instance.vm_stage_master.network_interface.0.nat_ip_address}"
  }

  depends_on = [
    local_file.ansible-inventory,
    local_file.k8s-kubespray
  ]
}