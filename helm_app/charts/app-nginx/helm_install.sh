set -e

# Установка на локальную машину Helm
cd ..

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh

# Ставим права на конф кубера под helm
chmod go-r ~/.kube/config
./get_helm.sh
# helm installed into /usr/local/bin/helm
