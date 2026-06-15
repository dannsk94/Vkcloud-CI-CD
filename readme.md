# Лабораторная работа: CI/CD пайплайн для VK Cloud

## 📋 Описание

Автоматизированное развертывание отказоустойчивой веб-инфраструктуры в VK Cloud с использованием Packer, Terraform и GitHub Actions. Проект демонстрирует подход "Инфраструктура как код" (IaC) и практики CI/CD.

## 🔄 Порядок работы

1. **Packer** — создание образа ВМ с nginx + PHP (при push/pull_request)
2. **Terraform** — развертывание инфраструктуры (validate → plan → apply)
3. **GitHub Actions** — автоматический CI/CD пайплайн
4. **Destroy** — удаление инфраструктуры (только ручной запуск)

## 📁 Структура проекта

```text
Vkcloud-CI-CD/
├── .github/workflows/
│   └── github-ci.yml              # CI/CD пайплайн
├── packer/
│   └── lab-packer-config.pkr.hcl  # Конфигурация Packer
├── terraform/
│   ├── main.tf                    # Провайдеры и backend
│   ├── variables.tf               # Переменные
│   ├── network.tf                 # Сеть, подсети, SG, ключ
│   ├── compute.tf                 # Бастион и веб-серверы
│   ├── database.tf                # PostgreSQL
│   ├── loadbalancer.tf            # Балансировщик
│   ├── outputs.tf                 # Выходные данные
│   ├── image.auto.tfvars          # ID образа Packer
│   └── terraform.tfvars           # Локальные значения (.gitignore)
├── .gitignore
└── README.md
```


## 🏗️ Архитектура

| Компонент | Описание |
|-----------|----------|
| **VPC** | Публичная 192.168.1.0/24, Приватная 192.168.2.0/24 |
| **Бастион** | SSH доступ, внешний IP |
| **Веб-серверы x2** | nginx + PHP-FPM, приватная подсеть |
| **Балансировщик** | L7 HTTP, Round Robin, Health Check |
| **PostgreSQL 15** | Управляемая БД, приватная подсеть, автобэкапы |

## 🚀 CI/CD Пайплайн

Файл: `.github/workflows/github-ci.yml`

### Jobs и условия запуска

| Job | Условие | Когда запускается |
|-----|---------|-------------------|
| `packer_build` | `event_name != 'workflow_dispatch'` | Push и Pull Request |
| `validate` | `event_name != 'workflow_dispatch' && !cancelled()` | Push и PR (после Packer) |
| `plan` | `event_name != 'workflow_dispatch' && !cancelled()` | Push и PR (после validate) |
| `apply` | `event_name != 'workflow_dispatch' && ref == 'main'` | Только push в main |
| `destroy` | `event_name == 'workflow_dispatch'` | Только ручной запуск |

### Передача данных
Packer → ID образа из логов → `image.auto.tfvars` → Artifact → Terraform

## 🔐 Безопасность

- Приватная подсеть для веб-серверов и БД
- Бастион — единая точка входа по SSH
- Все учетные данные в GitHub Secrets
- State хранится в S3 бакете
- `terraform.tfvars` в `.gitignore`

## 🛠️ Использование

### Локальный запуск
```bash
cd packer
packer build lab-packer-config.pkr.hcl
cd ../terraform
terraform init && terraform plan && terraform apply
```

## Автоматический запуск

1. Запушить изменения в `main`
2. Пайплайн запустится автоматически
3. Apply выполнится после plan (environment: production)

## Удаление

Actions → Packer + Terraform CI/CD → Run workflow → main → Run workflow

## 📝 Переменные

| Переменная | Описание | По умолчанию |
|------------|----------|--------------|
| `project_name` | Префикс имени ресурсов | `m05-demo` |
| `web_count` | Количество веб-серверов | `2` |
| `db_name` | Имя БД | `appdb` |
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

Запустить `workflow_dispatch` → Destroy удалит все ресурсы (35 ресурсов).