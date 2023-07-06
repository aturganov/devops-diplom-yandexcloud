set -e 

# https://www.digitalocean.com/community/tutorials/how-to-use-ansible-to-install-and-set-up-docker-on-ubuntu-20-04
ansible-playbook -i .ansible/inventory.ini docker.yaml 

# https://medium.com/@gustavo.guss/quick-tutorial-of-jenkins-b99d5f5889f2
docker run -d --name jenkins-docker -p 8080:8080 -p 50000:50000 \
-u root --restart on-failure \
-v /var/run/docker.sock:/var/run/docker.sock \
-v $PWD/jenkins-data:/var/jenkins_home aturganov/jenkins-docker
# 6eea0dd807e4481988d7f5f052e6d6d6

# https://github.com/aturganov/dip_nginx.git

# install helm
# https://blog.devops.dev/deploying-helm-charts-with-jenkins-and-groovy-a-comprehensive-guide-c2aa0f2bd424#:~:text=Install%20the%20Helm%20plugin%20for,and%20searching%20for%20%E2%80%9CHelm%E2%80%9D.