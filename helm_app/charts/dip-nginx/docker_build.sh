set -e

# При необходимости разрешаем подключение к Github 
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

# Создание образа с тагом версии
cd /home/locadm/git/dip_nginx
docker build . -t aturganov/dip-nginx:0.0.1

# Подьем в репу
docker push aturganov/dip-nginx:0.0.1

# Локальный тест
docker run -p 31000:80 aturganov/dip-nginx:0.0.1