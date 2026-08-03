# n8n Automation Portfolio

Портфолио готовых проектов автоматизации, созданных с помощью n8n.

## Projects / Проекты

### 1. NocoDB Queue Processor / Обработчик очереди NocoDB

Автоматическая обработка записей из очереди NocoDB с использованием основного workflow и вызываемого sub-workflow.

- Scheduled Runner — планировщик обработки очереди
- Process Single Request — обработка одной записи
- NocoDB — хранение входящих и обработанных данных
- Error handling — фиксация ошибок выполнения

[Открыть проект](projects/nocodb-queue-processor/README.md)

### 2. n8n Backup Automation / Автоматизация резервного копирования n8n

Production-oriented Bash script for automated backup and integrity verification of n8n and NocoDB.

Bash-скрипт для автоматического резервного копирования и проверки целостности n8n и NocoDB.

- PostgreSQL dumps — резервные копии баз n8n и NocoDB
- Workflow export — экспорт всех сценариев в JSON
- SHA256 verification — проверка целостности файлов
- Retention — автоматическое удаление старых копий
- Cron — ежедневный запуск по расписанию
- Restore testing — безопасная проверка восстановления

[Открыть проект](projects/n8n-backup-automation/README.md)

## Repository Structure / Структура репозитория

- `projects` — готовые проекты автоматизации
- `workflows` — экспортированные сценарии n8n
- `screenshots` — подтверждение работы сценариев
- `docs` — дополнительная документация
- `diagrams` — схемы процессов

## Security / Безопасность

Репозиторий не содержит:

- паролей;
- API-ключей;
- токенов доступа;
- ключей шифрования;
- резервных копий баз данных;
- файлов `.env`.

Конфиденциальные данные и резервные копии хранятся отдельно от Git-репозитория.