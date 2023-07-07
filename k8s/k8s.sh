# Подготовка инфры к кластеру k8s

set -e




# Переброс конфига для внешнего доступа
ansible-playbook -i ./terraform/.ansible/inventory.ini k8s_config.yaml \
    --extra-vars '{"external_ip":"51.250.103.200", "ansible_sudo_pass":"Temp001"}'


kubectl apply -f ./manifests/grafana-service.yml