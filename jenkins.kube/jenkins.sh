set -e 
# Handbook https://www.jenkins.io/doc/book/installing/kubernetes/#create-a-volume
# Установка плагинов в собственную сборку, не стал делать
# https://habr.com/ru/companies/southbridge/articles/699158/
# Запуск агентов на кубере
# https://github.com/jenkinsci/kubernetes-plugin
# 
# Работа с пайплайном
# https://www.youtube.com/watch?v=B_2FXWI6CWg

# https://www.jenkins.io/doc/book/using/using-agents/  


kubectl create namespace devops-tools

kubectl apply -f serviceAccount.yaml

kubectl create -f volume.yaml

kubectl apply -f service.yaml

kubectl --namespace=devops-tools logs jenkins-b96f7764f-7w2pw

# kubectl exec -it -n devops-tools jenkins-559d8cd85c-cfcgk cat /var/jenkins_home/secrets/initialAdminPassword

# 79c7e7d7c4904df7aaef38bcc47394d8

kubectl -n devops-tools get secret jenkins-admin-token-rbcr2 -o go-template --template '{{index .data "token"}}' | base64 -d ; echo

# https://devopscube.com/jenkins-build-agents-kubernetes/   
# https://51.250.103.200:6443


kubectl logs dip-pipe-master-9-mctxq-33v7t-tgtdt -n devops-tools

# https://sweetcode.io/how-to-build-and-push-docker-images-to-docker-hub-using-jenkins-pipeline/

docker run -d --rm --name=agent1 -p 4444:22 \
-e "JENKINS_AGENT_SSH_PUBKEY=ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDCm9scm5pizIFKDHxDbONPONMTf7ocEZrwJaBjd1MNaWEMHh4rl7IW6adLIYTGEj0jstXr7u4VsbYWfAS37x3IHm72SzHnYxd2MpangyIhTSKgY757zqwv+za18c6qzymZVEk0hdU6dU4lkBYa9vWZxYzpKstn1Y25rvH2BgnSkKxJmGV9FELuJ+lVY/nvVCK52q49DtKqxvs9FyI8dSRPliQVUANS1wDLPLi4EWBbttU2EJ6KaJj2l9V90xCo1S3FlxXtL3KbkrQFq2lJ+76NVSEzmNBZcQQouq2lL/ZMtIYNM559qqp5ucJ35l4b9T+L9mnxFwI1WvGqN4RiumlkWvx8zZJZpBw0r9/BuXfl+gSqF4N3udA0VIIYN+swLR6BQXggmDugXmurxyVJn5wp0Of3MALTCSsV0MVJ+ZS7X7J1woZrh4CsNcXq7TLWPAf1xg7G442X1yqCC45dpfvTNQtr97msTTnvitJFfnX4k4w2/+fVhwTWTZrJK94R80E= locadm@netology01" \
jenkins/ssh-agent:alpine


# https://www.jenkins.io/doc/book/using/using-agents/