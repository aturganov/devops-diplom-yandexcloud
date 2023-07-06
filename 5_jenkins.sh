set -e

# Подключаем репу
helm repo add jenkins https://charts.jenkins.io
helm repo update

# helm show values jenkins/jenkins > src/deploy/jenkins/values.yaml

kubectl create namespace jenkins

helm install jenkins jenkins/jenkins -n jenkins

# pv
# https://www.jenkins.io/doc/book/installing/kubernetes/#create-a-volume
# https://kubernetes.io/docs/tasks/configure-pod-container/security-context/


# helm install jenkins jenkins/jenkins -n jenkins -f jenkins/test.yaml
# helm uninstall jenkins -n jenkins

kubectl apply -f jenkins/jenkins-volume.yaml
kubectl delete -f jenkins/jenkins-volume.yaml

kubectl apply -f jenkins/jenkins-sa.yaml
kubectl delete -f jenkins/jenkins-sa.yaml

chart=jenkinsci/jenkins
helm install jenkins -n jenkins -f jenkins/jenkins-values.yaml $chart

