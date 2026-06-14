# Лабораторная работа №2: CI/CD пайплайн для инфраструктуры VK Cloud

## 📋 Описание

Автоматизированное развертывание отказоустойчивой веб-инфраструктуры в VK Cloud с использованием Terraform, Packer и GitHub Actions. Проект демонстрирует подход "Инфраструктура как код" (IaC) и практики непрерывной интеграции и доставки (CI/CD).

Автоматизированное развертывание инфраструктуры в VK Cloud с использованием Packer, Terraform и GitHub Actions.

## 🔄 Порядок работы

1. **Packer** — создание образа ВМ
2. **image-name.sh** — получение ID образа
3. **Terraform** — развертывание инфраструктуры
4. **GitHub Actions** — CI/CD пайплайн

## Структура проекта
```
lab2-cicd/
├── .github/
│   └── workflows/
│       └── github-ci.yml              # Пайплайн GitHub Actions
├── terraform/
│   ├── main.tf                        # Провайдеры и backend
│   ├── variables.tf                   # Переменные
│   ├── outputs.tf                     # Выходные данные
│   ├── network.tf                     # Сеть, подсети, безопасность
│   ├── compute.tf                     # Бастион и веб-серверы
│   ├── database.tf                    # База данных
│   ├── loadbalancer.tf                # Балансировщик
│   └── image.auto.tfvars              # ID образа Packer
├── packer/
│   ├── lab-packer-config.pkr.hcl      # Конфигурация образа
│   └── image-name.sh                  # Скрипт получения ID образа
└── README.md
```
## 🏗️ Архитектура

| Компонент | Описание |
|-----------|----------|
| **VPC** | Публичная подсеть 192.168.1.0/24, Приватная 192.168.2.0/24 |
| **Бастион** | SSH доступ, внешний IP |
| **Веб-серверы x2** | nginx + PHP-FPM, приватная подсеть |
| **Балансировщик** | L7 HTTP, Round Robin, Health Check |
| **PostgreSQL 15** | Управляемая БД, приватная подсеть, автобэкапы |

## 🚀 CI/CD Пайплайн

Файл: `.github/workflows/github-ci.yml`

### Этапы

1. **Validate** — `terraform init` + `terraform validate`
2. **Plan** — `terraform plan`, создание плана изменений
3. **Apply** — `terraform apply -auto-approve`, ручное подтверждение

### Триггеры

- Push в ветку `main`
- Pull Request в `main`

## 📦 Packer образ

Содержит:
- Ubuntu 22.04
- nginx + PHP-FPM + PHP-MySQLnd
- systemd автозапуск
- Тестовая страница
- Очищенные временные файлы и кэш apt

## 🔐 Безопасность

- Приватная подсеть для веб-серверов и БД
- Бастион — единая точка входа по SSH
- Security Groups с минимальными правилами
- State хранится в S3 бакете

## 🛠️ Использование

### Ручной запуск
```bash
cd packer
packer build lab-packer-config.pkr.hcl
bash image-name.sh
cd ../terraform
terraform init
terraform plan
terraform apply
```

## Автоматический запуск

1. Запушить изменения в `main`
2. Пайплайн запустится автоматически
3. Подтвердить `apply` вручную во вкладке **Actions**

## 📝 Переменные

| Переменная | Описание | По умолчанию |
|------------|----------|--------------|
| `project_name` | Префикс имени ресурсов | `m05-demo` |
| `web_count` | Количество веб-серверов | `2` |
| `db_name` | Имя базы данных | `appdb` |
| `db_user` | Пользователь БД | `appuser` |
| `image_name` | ID образа Packer | авто |

## 📤 Выходные данные

| Параметр | Описание |
|----------|----------|
| `bastion_public_ip` | Внешний IP бастиона |
| `load_balancer_public_ip` | Внешний IP балансировщика |
| `web_servers_private_ips` | Приватные IP веб-серверов |
| `db_host` | Приватный IP БД |
| `db_name` | Имя БД |

## 🧹 Очистка

```bash
cd terraform
terraform destroy -auto-approve
