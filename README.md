# n8n Automation Portfolio

Портфолио готовых проектов автоматизации, созданных с помощью n8n.

## Projects / Проекты
### 1. Automation Center / Центр автоматизации

Итоговый модульный проект курса: RAG-поиск, генерация ответа через OpenRouter, ежедневный запуск, email через UniSender, платёжные ссылки Robokassa и централизованная обработка ошибок.

- RAG и Qdrant — поиск информации в базе знаний
- OpenRouter — формирование ответа
- Schedule Trigger — ежедневный запуск в 09:00
- Sub-workflows — повторное использование общей логики
- UniSender — отправка писем и уведомлений
- Robokassa — тестовые платёжные ссылки
- Error Handler — централизованная обработка ошибок

[Открыть проект](projects/automation-center/README.md)
### 2. RAG-ассистент на базе Qdrant и Qwen

Интеллектуальный помощник, который индексирует собственный документ в векторной базе Qdrant, выполняет семантический поиск и формирует ответ на основании найденного контекста.

- Qwen3-Embedding-4B — создание векторных представлений текста
- Qdrant Cloud — хранение и семантический поиск
- OpenRouter — генерация итогового ответа
- Chunking — разделение документа на смысловые фрагменты
- RAG — ответы на основании собственной базы знаний
- HTTP Request — интеграция с Qdrant через REST API

[Открыть проект](projects/rag-qdrant-assistant/README.md)

### 3. NocoDB Queue Processor / Обработчик очереди NocoDB

Автоматическая обработка записей из очереди NocoDB с использованием основного workflow и вызываемого sub-workflow.

- Scheduled Runner — планировщик обработки очереди
- Process Single Request — обработка одной записи
- NocoDB — хранение входящих и обработанных данных
- Error handling — фиксация ошибок выполнения

[Открыть проект](projects/nocodb-queue-processor/README.md)

### 4. n8n Backup Automation / Автоматизация резервного копирования n8n

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