# Подготовка инфры к кластеру k8s
set -e

terraform init
terraform plan
terraform apply -auto-approve
# terraform destroy -auto-approve


# Запуск на мастере
ansible-playbook ~/kubespray/cluster.yml -i ~/kubespray/inventory/mycluster/inventory.ini --diff \
    --ssh-common-args='-o StrictHostKeyChecking=no'

# При необходимости открываем форвард для внешнего подключения
modprobe br_netfilter 
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-arptables=1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-ip6tables=1" >> /etc/sysctl.conf
echo 1 > /proc/sys/net/ipv4/ip_forward


# Проброс конфига на локалку для внешнего доступа kube
ansible-playbook -i ./terraform/.ansible/inventory.ini k8s_config.yaml \
    --extra-vars '{"external_ip":"51.250.103.200", "ansible_sudo_pass":"Temp001"}'
