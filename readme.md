# Создание облачной инфраструктуры
## 1. Сервисный аккаунт и bucket
В Яндекс Облаке при помощи Terraform создал сервис-аккаунт и назначил необходимые права
![alt text](image.png)

а так-же создал bucket на 1ГБ

![alt text](image1.png)

В дальнейшем сгенерил terraform-key.json сервисного аккаунта, который буду использовать для аутентификации при подготовке инфраструктуры.

Ссылка на код: https://github.com/shibegora/main_diplom/tree/main/terraform/service_account

## 2. Инфраструктура
В Яндекс Облаке при помощи Terraform было поднято

VPC c подсетями public и private
![alt text](image-2.png)

5 виртуальных машин

Одна виртуальная машина (master) в зоне public

Три виртуальных машины (worker) в зоне private

Одна виртуальная машина (nat-instance) в зоне public

Начальная конфигурация операционной системы на разных виртуальных машинах проходила через индивидуальный cloud-init

![alt text](image-3.png)

Так-же была создана таблица маршрутов из private на nat-instance для получения трафика виртуальным машинам в зоне private

![alt text](image-4.png)

Был создан Network Load Balancer и listener с targetport:30080

В target-group добавил worker-nodes

![alt text](image-5.png)

После применения кода, файл terraform.tfstate улетает в созданный ранее bucket

![alt text](image-6.png)

Ссылка на код: https://github.com/shibegora/main_diplom/tree/main/terraform/main_infrastructure

# Создание Kubernetes кластера
## Кластер

Kubernetes кластер подготавливал при помощи Kubespray, который запускал с master-node

git clone https://github.com/kubernetes-sigs/kubespray.git

Поставил зависимости

pip install -r ~/kubespray/requirements.txt

В файле с переменными ~/kubespray/inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml в параметре supplementary_addresses_in_ssl_keys подкинул nat-ip master-node

Заполняем inventory.ini

Одна мастер-нода, три воркер-ноды

![alt text](image-7.png)

Ожидание составило почти 13 минут

![alt text](image-8.png)

kubectl с ноутбука отрабатывает:

![alt text](image-9.png)

![alt text](image-10.png)

# Создание тестового приложения
Собрал docker образ тестового приложения и поместил его в DockerHub

![alt text](image-11.png)

![alt text](image-12.png)

Ссылка на dockerhub: https://hub.docker.com/repository/docker/shibegora/diploma_app/tags/1.0.0/sha256-c4f0f1d9ff9998f0c73473658e8e9f053cf460304204dfe7e29d59654ca05714

Ссылка на репозиторий: https://github.com/shibegora/test_app_k8s

# Подготовка cистемы мониторинга и деплой приложения
Клонирую репозиторий с заранее подготовленными конфигами для мониторинга и моего тестового приложения

Ссылка на репозиторий: https://github.com/shibegora/k8s_cfgs/tree/main

```git clone  https://github.com/shibegora/k8s_cfgs.git ```

## Grafana, prometheus, alertmanager, экспортер основных метрик Kubernetes

Систему мониторинга поднимал через helm

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

Запускаем установку с конфигом из склонированного ранее репозитория

helm upgrade --install kube-prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace -f ~/k8s_cfgs/kube-prom-values.yaml

Gragana доступна по адресу: http://51.250.44.216/grafana

![alt text](image-13.png)

![alt text](image-14.png)

## Тестовое приложение
Запускаем манифест из склонированного ранее репозитория

kubectl apply -f app_all_in_one.yml

Тестовое приложение доступно по адресу: http://51.250.44.216/app

![alt text](image-15.png)

## CI/CD-terraform
Создал workflow в GitHub Actions, который при любом пуше в main запускает пайплайн

Сам Workflow: https://github.com/shibegora/main_diplom/blob/main/.github/workflows/terraform.yml

Как видно пайплайн прошел успешно

![alt text](image-16.png)

Для проверки, поменял размер ОЗУ на nat instance с 2 до 3 гб. Как видно, ВМ остановилась:

![alt text](image-17.png)

И запустилась уже с 3 гб ОЗУ:

![alt text](image-18.png)

Все измнения прошли за 1.2 минуты:
![alt text](image-19.png)

# Установка и настройка CI/CD
В репозитории с тестовым приложением создал workflow в GitHub Actions, который при любом пуше в main запускает пайплайн где со бирает образ приложения и отправляет его в DockerHub

А так-же если пуш происходит с тегом, приложение деплоится в кубернетес кластер

Сам Workflow: https://github.com/shibegora/test_app_k8s/blob/main/.github/workflows/deploy.yaml

Репозиторий с тестовым приложением: https://github.com/shibegora/test_app_k8s

## Демонстрация работы
Внес изменения в репозитории и сделал пуш без тага

![alt text](image-20.png)

Как видим запустился пайплайн

![alt text](image-21.png)

Который завершился успешно, но не попал в деплой

![alt text](image-22.png)

Теперь внес изменения в репозитории и сделал пуш с тагом

Для наглядности внес изменение в страничку со статичными данными. Записал туда версию приложения, которую укажу в таге: 1.0.14

![alt text](image-23.png)

![alt text](image-24.png)

Как видим пайплайн прошел успешно и приложение задеплоилось в кластер

![alt text](image-25.png)

![alt text](image-26.png)

Образ используемый для переразворачивания ВМ так же изменился:

![alt text](image-27.png)

Версия приложения так же поменялась:

![alt text](image-28.png)

А в Dockerhub залетел используемый образ:

![alt text](image-29.png)