# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---

### Решение: 
### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
```
Скидок нет, будем накатывать постепенно.
```
- Следует использовать последнюю стабильную версию [Terraform](https://www.terraform.io/).

```
Обновляем terraform
locadm@netology01:~/git$ terraform -version
Terraform v1.5.0
on linux_amd64
```

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя

Создание сервисного аккаунта, права, ключи доступа, создание пустого бакета

[bucket.tf](terraform_adm/bucket.tf)
```
locadm@netology01:~/git/devops-diplom-yandexcloud/terraform_adm$  yc iam service-account list
+----------------------+------+
|          ID          | NAME |
+----------------------+------+
| aje71inplmi2dm31bb1u | sa   |
+----------------------+------+
```
<!-- ![1.PNG](pics/1.PNG) -->
```
locadm@netology01:~/git/devops-diplom-yandexcloud/terraform_adm$ yc iam access-key list --service-account-name sa
+----------------------+----------------------+---------------------------+
|          ID          |  SERVICE ACCOUNT ID  |          KEY ID           |
+----------------------+----------------------+---------------------------+
| aje3a8o8uj5pus5jr9gb | aje71inplmi2dm31bb1u | YCAJEQIazPRtyh5DchRVzMgg1 |
+----------------------+----------------------+---------------------------+
```

Права на доступ к бакету

[2.PNG](pics/2.PNG)
```
Пустой бакет
locadm@netology01:~/git/devops-diplom-yandexcloud/terraform_adm$ yc storage bucket list
+------------+----------------------+----------+-----------------------+---------------------+
|    NAME    |      FOLDER ID       | MAX SIZE | DEFAULT STORAGE CLASS |     CREATED AT      |
+------------+----------------------+----------+-----------------------+---------------------+
| prj-bucket | b1gkgthf18fqkuii66ht |        0 | STANDARD              | 2023-06-29 19:48:06 |
+------------+----------------------+----------+-----------------------+---------------------+
```
![3.PNG](pics/3.PNG)
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: [Terraform Cloud](https://app.terraform.io/)  
   б. Альтернативный вариант: S3 bucket в созданном ЯО аккаунте
```
Идем по s3
Создал backend на базе бакета выше. В бакет сохраняется tfstate.
```
[provider.tf](terraform/provider.tf)
![4.PNG](pics/4.PNG)
3. Настройте [workspaces](https://www.terraform.io/docs/language/state/workspaces.html)  
   а. Рекомендуемый вариант: создайте два workspace: *stage* и *prod*. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.  
   б. Альтернативный вариант: используйте один workspace, назвав его *stage*. Пожалуйста, не используйте workspace, создаваемый Terraform-ом по-умолчанию (*default*).
```
Идем по альтернативному пути

Создаем 
terraform workspace new stage

locadm@netology01:~/git/devops-diplom-yandexcloud/terraform$ terraform workspace select stage
...
Switched to workspace "stage".

default
* stage
```
![5.PNG](pics/5.PNG)
4. Создайте VPC с подсетями в разных зонах доступности.
```
Создадим подсети в разных зонах доступности
locadm@netology01:~/git/devops-diplom-yandexcloud/terraform$ yc vpc network list-subnets network
+----------------------+--------+----------------------+----------------------+----------------+---------------+-------------------+
|          ID          |  NAME  |      FOLDER ID       |      NETWORK ID      | ROUTE TABLE ID |     ZONE      |       RANGE       |
+----------------------+--------+----------------------+----------------------+----------------+---------------+-------------------+
| b0c1j531u9turjbu5dsv | prod   | b1gkgthf18fqkuii66ht | enp1kpenkl1i14jjuple |                | ru-central1-c | [192.168.20.0/24] |
| e2lhgdrgm1hvbo0aguv7 | stage  | b1gkgthf18fqkuii66ht | enp1kpenkl1i14jjuple |                | ru-central1-b | [192.168.10.0/24] |
| e9b2rda1rjuu22m0o663 | manage | b1gkgthf18fqkuii66ht | enp1kpenkl1i14jjuple |                | ru-central1-a | [192.168.30.0/24] |
+----------------------+--------+----------------------+----------------------+----------------+---------------+-------------------+
```
[network.tf](terraform/network.tf)
![6.PNG](pics/6.PNG)

5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
```
Удаление объектов
```
![7.PNG](pics/7.PNG)
```
Создание. Как видно не требует усилий в workspace stage
```
![8.PNG](pics/8.PNG)

6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.
```
В случае s3 не предполагается.
```

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---
### Создание Kubernetes кластера
https://internet-lab.ru/k8s_kubespray

```
https://github.com/kubernetes-sigs/kubespray

declare -a IPS=(192.168.10.21 192.168.10.32 192.168.10.35)
CONFIG_FILE=./kubespray/inventory/mycluster/hosts.yaml python3 ~/kubespray/contrib/inventory_builder/inventory.py ${IPS[@]}


ansible-playbook -i ./.ansible/inventory.ini kuberspray.yaml
```

```
Sunday 25 June 2023  20:39:06 +0000 (0:00:00.145)       0:15:56.505 *********** 
=============================================================================== 
kubernetes/preinstall : Install packages requirements ------------------------------------------------------------- 37.71s
network_plugin/calico : Wait for calico kubeconfig to be created -------------------------------------------------- 22.68s
kubernetes/control-plane : Master | wait for kube-scheduler ------------------------------------------------------- 21.07s
kubernetes/control-plane : kubeadm | Initialize first master ------------------------------------------------------ 19.68s
kubernetes/kubeadm : Join to cluster ------------------------------------------------------------------------------ 16.86s
kubernetes/preinstall : Update package management cache (APT) ----------------------------------------------------- 15.04s
kubernetes-apps/ansible : Kubernetes Apps | Start Resources ------------------------------------------------------- 12.60s
download : download_container | Download image if required -------------------------------------------------------- 11.76s
kubernetes-apps/ansible : Kubernetes Apps | Lay Down CoreDNS templates -------------------------------------------- 11.28s
download : download_container | Download image if required -------------------------------------------------------- 10.11s
download : download_container | Download image if required --------------------------------------------------------- 9.87s
kubernetes/preinstall : Preinstall | wait for the apiserver to be running ------------------------------------------ 7.78s
network_plugin/calico : Start Calico resources --------------------------------------------------------------------- 7.12s
container-engine/containerd : containerd | Unpack containerd archive ----------------------------------------------- 6.81s
etcd : reload etcd ------------------------------------------------------------------------------------------------- 6.68s
download : download_file | Download item --------------------------------------------------------------------------- 6.68s
download : download_container | Download image if required --------------------------------------------------------- 6.43s
network_plugin/calico : Calico | Create calico manifests ----------------------------------------------------------- 6.33s
container-engine/containerd : download_file | Download item -------------------------------------------------------- 6.27s
container-engine/crictl : extract_file | Unpacking archive --------------------------------------------------------- 6.09s
```
```
ansible-playbook ~/kubespray/cluster.yml -i ~/kubespray/inventory/mycluster/inventory.ini --diff
```


```
root@stage-master:~/kubespray# kubectl get pods --all-namespaces
NAMESPACE     NAME                                      READY   STATUS    RESTARTS        AGE
kube-system   calico-kube-controllers-6dfcdfb99-whhl6   1/1     Running   0               5m
kube-system   calico-node-6j92v                         1/1     Running   0               5m55s
kube-system   calico-node-d6q2t                         1/1     Running   0               5m55s
kube-system   calico-node-nm89p                         1/1     Running   0               5m55s
kube-system   coredns-645b46f4b6-w6qtk                  1/1     Running   0               4m27s
kube-system   coredns-645b46f4b6-x9jgc                  1/1     Running   0               4m34s
kube-system   dns-autoscaler-659b8c48cb-78lj2           1/1     Running   0               4m29s
kube-system   kube-apiserver-node1                      1/1     Running   1               7m57s
kube-system   kube-controller-manager-node1             1/1     Running   2               7m58s
kube-system   kube-proxy-677kv                          1/1     Running   0               6m38s
kube-system   kube-proxy-7lzjt                          1/1     Running   0               6m38s
kube-system   kube-proxy-qlvt4                          1/1     Running   0               6m38s
kube-system   kube-scheduler-node1                      1/1     Running   2 (7m32s ago)   7m55s
kube-system   nginx-proxy-node2                         1/1     Running   0               5m35s
kube-system   nginx-proxy-node3                         1/1     Running   0               5m37s
kube-system   nodelocaldns-c6tf5                        1/1     Running   0               4m26s
kube-system   nodelocaldns-r7s8c                        1/1     Running   0               4m26s
kube-system   nodelocaldns-zvl62                        1/1     Running   0               4m26s
```

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

```
!!! Добавить IP
k8s-cluster.yml 
## Supplementary addresses that can be added in kubernetes ssl keys.
## That can be useful for example to setup a keepalived virtual IP
supplementary_addresses_in_ssl_keys: [51.250.105.5]
```

```
https://cloud.yandex.com/en/docs/container-registry/operations/registry/registry-create
```

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   ```

   ```   
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.

2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать региональный мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)

  ```
  Открываем доступ извне
  ip-forward не включен
Включаем форвард
sudo -iip
modprobe br_netfilter 
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-arptables=1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-ip6tables=1" >> /etc/sysctl.conf
echo 1 > /proc/sys/net/ipv4/ip_forward
  ```
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.


```
docker build . -t aturganov/nginx-stage
docker run -d --name nginx aturganov/nginx-stage
docker push aturganov/nginx-stage
https://hub.docker.com/repository/docker/aturganov/nginx-stage/general
```
Репозиторий:
https://github.com/aturganov/dip_nginx

Проблема с подключение к хосту git, добавляем хост на локальную машину
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

Деплой:

locadm@netology01:~/git/devops-diplom-yandexcloud/terraform$ kubectl create deploy nginx --image=aturganov/nginx-stage:latest --replicas=3
deployment.apps/nginx created

locadm@netology01:~/git/devops-diplom-yandexcloud/terraform$ kubectl get pods -o wide
NAME                    READY   STATUS    RESTARTS   AGE   IP            NODE    NOMINATED NODE   READINESS GATES
nginx-6fdccc7f9-7x2q9   1/1     Running   0          63s   10.233.96.2   node2   <none>           <none>
nginx-6fdccc7f9-ln4xl   1/1     Running   0          63s   10.233.92.2   node3   <none>           <none>
nginx-6fdccc7f9-rhpbm   1/1     Running   0          63s   10.233.96.1   node2   <none>           <none>

```
```
Список текущих подов
locadm@netology01:~/git/devops-diplom-yandexcloud/terraform$  kubectl get pods --namespace=kube-system -o wide
NAME                                       READY   STATUS    RESTARTS      AGE   IP              NODE    NOMINATED NODE   READINESS GATES
calico-kube-controllers-6dd874f784-gd87g   1/1     Running   0             82m   192.168.10.13   node2   <none>           <none>
calico-node-8d8x5                          1/1     Running   0             83m   192.168.10.17   node3   <none>           <none>
calico-node-cms8k                          1/1     Running   0             83m   192.168.10.21   node1   <none>           <none>
calico-node-qc2s7                          1/1     Running   0             83m   192.168.10.13   node2   <none>           <none>
coredns-76b4fb4578-26gdl                   1/1     Running   0             81m   10.233.92.1     node3   <none>           <none>
coredns-76b4fb4578-sxdhh                   1/1     Running   0             81m   10.233.90.1     node1   <none>           <none>
dns-autoscaler-7979fb6659-n4f9g            1/1     Running   0             81m   10.233.90.2     node1   <none>           <none>
kube-apiserver-node1                       1/1     Running   1             84m   192.168.10.21   node1   <none>           <none>
kube-controller-manager-node1              1/1     Running   2 (80m ago)   84m   192.168.10.21   node1   <none>           <none>
kube-proxy-86czm                           1/1     Running   0             83m   192.168.10.21   node1   <none>           <none>
kube-proxy-w2f9t                           1/1     Running   0             83m   192.168.10.13   node2   <none>           <none>
kube-proxy-wf22s                           1/1     Running   0             83m   192.168.10.17   node3   <none>           <none>
kube-scheduler-node1                       1/1     Running   2 (80m ago)   84m   192.168.10.21   node1   <none>           <none>
nginx-proxy-node2                          1/1     Running   0             83m   192.168.10.13   node2   <none>           <none>
nginx-proxy-node3                          1/1     Running   0             83m   192.168.10.17   node3   <none>           <none>
nodelocaldns-9g9j2                         1/1     Running   0             81m   192.168.10.21   node1   <none>           <none>
nodelocaldns-hk25r                         1/1     Running   0             81m   192.168.10.13   node2   <none>           <none>
nodelocaldns-rjt27                         1/1     Running   0             81m   192.168.10.17   node3   <none>           <none>
locadm@
```




root@node1:~/kube-prometheus# helm version
version.BuildInfo{Version:"v3.12.1", GitCommit:"f32a527a060157990e2aa86bf45010dfb3cc8b8d", GitTreeState:"clean", GoVersion:"go1.20.4"}

root@node1:~/kube-prometheus# kubectl create ns monitoring
namespace/monitoring created

root@node1:~#  git clone https://github.com/coreos/prometheus-operator.git
cd prometheus-operator

helm repo add stable https://charts.helm.sh/stable
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm search repo prometheus-community

Установка
helm install stable prometheus-community/kube-prometheus-stack

root@node1:~/prometheus-operator# helm install stable prometheus-community/kube-prometheus-stack
NAME: stable
LAST DEPLOYED: Sat Jul  1 14:11:09 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace default get pods -l "release=stable"

https://stackoverflow.com/questions/44110876/kubernetes-service-external-ip-pending
https://kubernetes.io/docs/concepts/services-networking/ingress/

```
Kubernetes NodePort vs LoadBalancer vs Ingress? Когда и что использовать?
https://habr.com/ru/companies/southbridge/articles/358824/


```
Документация:
https://github.com/prometheus-operator/kube-prometheus

kubectl apply --server-side -f manifests/setup
root@stage-master:~/kube-prometheus/manifests# kubectl get ns
NAME              STATUS   AGE
default           Active   5h26m
kube-node-lease   Active   5h26m
kube-public       Active   5h26m
kube-system       Active   5h26m
monitoring        Active   69s

kubectl wait --for=condition=Established --all CustomResourceDefinition --namespace=monitoring
root@stage-master:~/kube-prometheus# kubectl wait --for=condition=Established --all CustomResourceDefinition --namespace=monitoring
customresourcedefinition.apiextensions.k8s.io/alertmanagerconfigs.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/alertmanagers.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/bgpconfigurations.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/bgppeers.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/blockaffinities.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/caliconodestatuses.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/clusterinformations.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/felixconfigurations.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/globalnetworkpolicies.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/globalnetworksets.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/hostendpoints.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/ipamblocks.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/ipamconfigs.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/ipamhandles.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/ippools.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/ipreservations.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/kubecontrollersconfigurations.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/networkpolicies.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/networksets.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/podmonitors.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/probes.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/prometheuses.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/prometheusrules.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/servicemonitors.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/thanosrulers.monitoring.coreos.com condition met

root@stage-master:~/kube-prometheus# kubectl apply -f manifests/

root@stage-master:~/kube-prometheus# kubectl get pods --namespace=monitoring
NAME                                  READY   STATUS    RESTARTS        AGE
alertmanager-main-0                   1/2     Running   3 (3s ago)      28m
alertmanager-main-1                   1/2     Running   0               57s
alertmanager-main-2                   1/2     Running   3 (7s ago)      28m
blackbox-exporter-746c64fd88-9pbw2    3/3     Running   3 (2m44s ago)   28m
grafana-5fc7f9f55d-z4plm              1/1     Running   1 (2m46s ago)   28m
kube-state-metrics-6c8846558c-7w4wp   3/3     Running   0               113s
node-exporter-chzcg                   2/2     Running   2 (2m45s ago)   28m
node-exporter-mk6db                   2/2     Running   0               28m
node-exporter-s4sfr                   2/2     Running   2 (113s ago)    28m
prometheus-adapter-6455646bdc-k9v7m   1/1     Running   0               113s
prometheus-adapter-6455646bdc-n4vqs   1/1     Running   1 (2m46s ago)   28m
prometheus-k8s-0                      2/2     Running   0               57s
prometheus-k8s-1                      2/2     Running   0               28m
prometheus-operator-f59c8b954-kfz8j   2/2     Running   2 (2m44s ago)   28m

Тупо удаляем: 
kubectl delete -n monitoring networkpolicy grafana
kubectl logs -n monitoring grafana-5fc7f9f55d-w7c76

```


```

kubectl create namespace monitoring

root@node1:~# helm upgrade --install prometheus prometheus-community/kube-prometheus-stack -n monitoring
Release "prometheus" has been upgraded. Happy Helming!
NAME: prometheus
LAST DEPLOYED: Mon Jul  3 20:45:00 2023
NAMESPACE: monitoring
STATUS: deployed
REVISION: 2
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=prometheus"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
kubectl apply -f ./manifests/grafana-service.yml
kubectl get secret --namespace monitoring

locadm@netology01:~/git/devops-diplom-yandexcloud/terraform$ kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="
{.data.admin-password}" | base64 --decode ; echo
prom-operator


```