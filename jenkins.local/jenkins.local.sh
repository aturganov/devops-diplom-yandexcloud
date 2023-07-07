set -e 

# https://www.digitalocean.com/community/tutorials/how-to-use-ansible-to-install-and-set-up-docker-on-ubuntu-20-04
ansible-playbook -i .ansible/inventory.ini docker.yaml 

# Сборка образа jenkins с docker, kubectl, helm
# https://stackoverflow.com/questions/63994247/how-to-install-kubectl-and-helm-using-dockerfile

sudo docker build . -t aturganov/jenkins-docker-kubectl-helm -f jenkins.local/dockerfile.local --no-cache
docker push aturganov/jenkins-docker-kubectl-helm 

# Запуск jenkins
# https://medium.com/@gustavo.guss/quick-tutorial-of-jenkins-b99d5f5889f2
# docker run -d --name jenkins-docker -p 8080:8080 -p 50000:50000 \
# -u root --restart on-failure \
# -v /var/run/docker.sock:/var/run/docker.sock \
# -v $PWD/jenkins-data:/var/jenkins_home aturganov/jenkins-docker
docker run -d --name jenkins -p 8080:8080 -p 50000:50000 \
-u root --restart on-failure \
-v /var/run/docker.sock:/var/run/docker.sock \
-v $PWD/jenkins-data:/var/jenkins_home aturganov/jenkins-docker-kubectl-helm:0.0.3

docker exec -it -u root jenkins bash

# vim root/.ssh/config
kubectl get pods --all-namespace


# https://github.com/aturganov/dip_nginx.git

# install helm
# https://blog.devops.dev/deploying-helm-charts-with-jenkins-and-groovy-a-comprehensive-guide-c2aa0f2bd424#:~:text=Install%20the%20Helm%20plugin%20for,and%20searching%20for%20%E2%80%9CHelm%E2%80%9D.


