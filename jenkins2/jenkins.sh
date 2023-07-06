set -e 
# Handbook https://www.jenkins.io/doc/book/installing/kubernetes/#create-a-volume
# Установка плагинов в собственную сборку, не стал делать
# https://habr.com/ru/companies/southbridge/articles/699158/
# Запуск агентов на кубере
# https://github.com/jenkinsci/kubernetes-plugin
# 
# Работа с пайплайном
# https://www.youtube.com/watch?v=B_2FXWI6CWg
#   


kubectl create namespace devops-tools

kubectl apply -f serviceAccount.yaml

kubectl create -f volume.yaml

kubectl apply -f service.yaml

kubectl --namespace=devops-tools logs jenkins-b96f7764f-7w2pw

# kubectl exec -it -n devops-tools jenkins-559d8cd85c-cfcgk cat /var/jenkins_home/secrets/initialAdminPassword

79c7e7d7c4904df7aaef38bcc47394d8

