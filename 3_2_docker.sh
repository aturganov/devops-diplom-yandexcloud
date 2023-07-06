set -e

# Создание образа с тагом версии
cd /home/locadm/git/dip_nginx
docker build . -t aturganov/nginx-stage2:0.0.2

# Подьем в репу
docker push aturganov/nginx-stage2:0.0.2

# Локальный тест
docker run -p 31000:80 aturganov/nginx-stage2:0.0.2