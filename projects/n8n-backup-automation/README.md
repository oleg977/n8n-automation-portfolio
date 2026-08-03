# n8n Backup Automation / Автоматизация резервного копирования n8n

Production-oriented Bash script for automated n8n and NocoDB backups.

Bash-скрипт для автоматического резервного копирования n8n и NocoDB, проверки целостности и ротации локальных копий.

## Features / Возможности

Скрипт автоматически:

* экспортирует все workflow n8n в JSON;
* создаёт дамп PostgreSQL базы n8n;
* создаёт дамп PostgreSQL базы NocoDB;
* сохраняет конфигурацию n8n с ключом шифрования;
* сохраняет `docker-compose.yml`;
* копирует старую `noco.db`, если файл существует;
* записывает версии n8n, Docker-образов и количество workflow;
* создаёт контрольные суммы SHA256;
* проверяет контрольные суммы до завершения бэкапа;
* удаляет локальные копии старше установленного срока;
* очищает временные файлы при ошибке.

## Tested Environment / Проверенное окружение

* Ubuntu 22.04 LTS;
* Docker;
* Docker Compose;
* n8n `2.31.5`;
* PostgreSQL `17`;
* NocoDB с PostgreSQL;
* запуск от пользователя `root`.

## Backup Contents / Состав резервной копии

Каждая готовая копия содержит:

* `database/n8n-postgres.dump` — база n8n;
* `database/nocodb-postgres.dump` — база NocoDB;
* `workflows/*.json` — экспортированные workflow;
* `config/n8n-config` — конфигурация n8n и encryption key;
* `config/docker-compose.yml` — конфигурация контейнеров;
* `nocodb-data/noco.db` — старая локальная база NocoDB, если существует;
* `BACKUP_INFO.txt` — дата, версии образов и количество workflow;
* `SHA256SUMS` — контрольные суммы всех файлов.

## Security Warning / Предупреждение безопасности

Резервная копия содержит конфиденциальные данные:

* ключ шифрования n8n;
* зашифрованные credentials из базы n8n;
* настройки контейнеров;
* данные NocoDB;
* пользовательские workflow.

Резервные копии нельзя добавлять в Git, отправлять в открытые облачные папки или хранить с публичными правами доступа.

Рекомендуемые права:

```bash
chmod 700 /opt/n8n/backups
chmod 700 /usr/local/sbin/n8n-backup.sh
```

Перед переносом на другой сервер или компьютер полный архив следует зашифровать.

## Configuration / Настройка

Скрипт поддерживает следующие переменные окружения:

| Variable          | Default value                 | Назначение              |
| ----------------- | ----------------------------- | ----------------------- |
| `BACKUP_ROOT`     | `/opt/n8n/backups/daily`      | Каталог резервных копий |
| `RETENTION_DAYS`  | `14`                          | Срок хранения в днях    |
| `N8N_CONTAINER`   | `n8n-n8n-1`                   | Контейнер n8n           |
| `PG_CONTAINER`    | `n8n-postgres-1`              | Контейнер PostgreSQL    |
| `PG_USER`         | `n8n_user`                    | Пользователь PostgreSQL |
| `N8N_DATABASE`    | `n8n_db`                      | База данных n8n         |
| `NOCODB_DATABASE` | `nocodb_db`                   | База данных NocoDB      |
| `N8N_CONFIG`      | путь Docker volume            | Конфигурация n8n        |
| `COMPOSE_FILE`    | `/opt/n8n/docker-compose.yml` | Docker Compose          |
| `LEGACY_NOCO_DB`  | путь к `noco.db`              | Старая база NocoDB      |

Значения по умолчанию соответствуют проверенной конфигурации сервера. Их можно переопределить без редактирования скрипта.

Пример:

```bash
BACKUP_ROOT=/srv/n8n-backups \
RETENTION_DAYS=30 \
/usr/local/sbin/n8n-backup.sh
```

## Installation / Установка

Скопируйте скрипт на сервер:

```bash
install -m 700 scripts/n8n-backup.sh /usr/local/sbin/n8n-backup.sh
```

Проверьте синтаксис:

```bash
bash -n /usr/local/sbin/n8n-backup.sh
```

## Manual Run / Ручной запуск

```bash
/usr/local/sbin/n8n-backup.sh
```

Пример успешного результата:

```text
Successfully exported 24 workflows.
BACKUP_OK: /opt/n8n/backups/daily/2026-08-01_14-31-13
```

Если строка `BACKUP_OK` не появилась, копия не должна считаться завершённой.

## Scheduled Run / Запуск по расписанию

Пример `/etc/cron.d/n8n-backup`:

```cron
0 3 * * * root /usr/local/sbin/n8n-backup.sh >> /var/log/n8n-backup.log 2>&1
```

Скрипт будет запускаться ежедневно в `03:00`.

Проверка cron:

```bash
systemctl is-active cron
cat /etc/cron.d/n8n-backup
tail -n 20 /var/log/n8n-backup.log
```

## Checksum Verification / Проверка контрольных сумм

Перейдите в каталог конкретной копии:

```bash
cd /opt/n8n/backups/daily/2026-08-01_14-31-13
```

Проверьте все файлы:

```bash
sha256sum --quiet -c SHA256SUMS && echo "BACKUP_CHECKSUMS=OK"
```

Ожидаемый результат:

```text
BACKUP_CHECKSUMS=OK
```

## Retention / Ротация

По умолчанию удаляются каталоги старше 14 дней:

```bash
RETENTION_DAYS=14
```

При ежедневном запуске это обеспечивает примерно две недели локальной истории. Это ротация по возрасту, а не строгое хранение ровно 14 каталогов.

Перед уменьшением срока хранения необходимо убедиться, что копии успешно передаются на отдельный сервер или компьютер.

## Safe Restore Check / Безопасная проверка восстановления

Не восстанавливайте дамп поверх рабочей базы без отдельного плана.

Проверить структуру дампа без восстановления:

```bash
docker exec -i n8n-postgres-1 pg_restore -l \
< database/n8n-postgres.dump |
head -n 15
```

Проверить количество экспортированных workflow:

```bash
find workflows -type f -name '*.json' | wc -l
```

Полная проверка восстановления должна выполняться в отдельной тестовой базе или тестовом окружении.

## Troubleshooting / Типичные ошибки

### Container is not running

Причина: контейнер n8n или PostgreSQL остановлен.

Проверка:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

### Permission denied

Причина: скрипт запущен не от `root` или отсутствуют права на каталог.

Проверка:

```bash
stat /usr/local/sbin/n8n-backup.sh
stat /opt/n8n/backups
```

### Database does not exist

Причина: неверно указано имя базы данных.

Проверка:

```bash
docker exec n8n-postgres-1 \
psql -U n8n_user -d postgres -c "\l"
```

### No space left on device

Причина: на сервере закончилось свободное место.

Проверка:

```bash
df -h
du -sh /opt/n8n/backups/*
```

### Checksum verification failed

Причина: файл изменён, повреждён или был скопирован не полностью.

Действие: не использовать такую копию для восстановления; создать новый бэкап и повторить проверку.

### Script works manually but not from cron

Причина: ограниченное окружение cron или неправильный путь.

Проверка:

```bash
env -i HOME=/root SHELL=/bin/sh PATH=/usr/bin:/bin \
/usr/local/sbin/n8n-backup.sh
```

## Storage Strategy / Стратегия хранения

Используется правило нескольких уровней:

1. ежедневные копии на сервере;
2. несколько версий с датой и временем в названии;
3. контрольные суммы SHA256;
4. зашифрованная копия на отдельном компьютере;
5. периодическая тестовая проверка восстановления.

Локальная копия защищает от ошибки приложения, но не защищает от полной потери сервера. Поэтому минимум одна актуальная копия должна храниться отдельно.

## Important Notes / Важные замечания

* Скрипт не выводит и не экспортирует credentials в расшифрованном виде.
* Файл `n8n-config` необходим для расшифровки credentials после восстановления.
* PostgreSQL-дампы создаются в формате `custom`.
* Каталог сначала создаётся как временный и становится готовым только после успешной проверки SHA256.
* Перед обновлением n8n рекомендуется выполнить дополнительную ручную копию.
