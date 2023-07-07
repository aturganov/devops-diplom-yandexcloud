set -e

# app helm templating - обзор/проверка
helm template ./helm_app/charts/app-nginx

# deploy 
# создаем app-stage
kubectl create ns stage --dry-run=client

helm upgrade --install app-nginx ./helm_app/charts/app-nginx
# helm uninstall app-nginx


# helm upgrade --install app-nginx ./helm/charts/app-nginx
