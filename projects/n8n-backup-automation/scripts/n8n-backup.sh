#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

BACKUP_ROOT="${BACKUP_ROOT:-/opt/n8n/backups/daily}"
RETENTION_DAYS="${RETENTION_DAYS:-14}"

BACKUP_STAMP="$(date +%F_%H-%M-%S)"
FINAL_DIR="${BACKUP_ROOT}/${BACKUP_STAMP}"
TEMP_DIR="${BACKUP_ROOT}/.${BACKUP_STAMP}.tmp"

N8N_CONTAINER="${N8N_CONTAINER:-n8n-n8n-1}"
PG_CONTAINER="${PG_CONTAINER:-n8n-postgres-1}"
PG_USER="${PG_USER:-n8n_user}"
N8N_DATABASE="${N8N_DATABASE:-n8n_db}"
NOCODB_DATABASE="${NOCODB_DATABASE:-nocodb_db}"

WORKFLOW_TMP="/tmp/n8n-workflows-${BACKUP_STAMP}"

N8N_CONFIG="${N8N_CONFIG:-/var/lib/docker/volumes/n8n_n8n_data/_data/config}"
COMPOSE_FILE="${COMPOSE_FILE:-/opt/n8n/docker-compose.yml}"
LEGACY_NOCO_DB="${LEGACY_NOCO_DB:-/var/lib/docker/volumes/n8n_nocodb_data/_data/noco.db}"

cleanup() {
    docker exec "$N8N_CONTAINER" rm -rf -- "$WORKFLOW_TMP" >/dev/null 2>&1 || true

    if [ -d "$TEMP_DIR" ]; then
        rm -rf -- "$TEMP_DIR"
    fi
}

trap cleanup EXIT

for container in "$N8N_CONTAINER" "$PG_CONTAINER"; do
    if [ "$(docker inspect -f '{{.State.Running}}' "$container")" != "true" ]; then
        echo "ERROR: container is not running: $container"
        exit 1
    fi
done

install -d -m 700 "$BACKUP_ROOT"
mkdir -p \
    "$TEMP_DIR/database" \
    "$TEMP_DIR/config" \
    "$TEMP_DIR/workflows" \
    "$TEMP_DIR/nocodb-data"

docker exec "$PG_CONTAINER" \
    pg_dump -U "$PG_USER" -d "$N8N_DATABASE" -Fc \
    > "$TEMP_DIR/database/n8n-postgres.dump"

docker exec "$PG_CONTAINER" \
    pg_dump -U "$PG_USER" -d "$NOCODB_DATABASE" -Fc \
    > "$TEMP_DIR/database/nocodb-postgres.dump"

install -m 600 "$N8N_CONFIG" "$TEMP_DIR/config/n8n-config"
install -m 600 "$COMPOSE_FILE" "$TEMP_DIR/config/docker-compose.yml"

if [ -f "$LEGACY_NOCO_DB" ]; then
    install -m 600 "$LEGACY_NOCO_DB" "$TEMP_DIR/nocodb-data/noco.db"
fi

docker exec "$N8N_CONTAINER" mkdir -p "$WORKFLOW_TMP"

docker exec "$N8N_CONTAINER" \
    n8n export:workflow --backup --output="$WORKFLOW_TMP/"

docker cp \
    "$N8N_CONTAINER:$WORKFLOW_TMP/." \
    "$TEMP_DIR/workflows/"

{
    echo "backup_timestamp=$BACKUP_STAMP"
    echo "hostname=$(hostname)"
    echo "n8n_version=$(docker exec "$N8N_CONTAINER" n8n --version)"
    echo "n8n_image=$(docker inspect -f '{{.Config.Image}}' "$N8N_CONTAINER")"
    echo "postgres_image=$(docker inspect -f '{{.Config.Image}}' "$PG_CONTAINER")"
    echo "workflow_files=$(find "$TEMP_DIR/workflows" -type f -name '*.json' | wc -l)"
} > "$TEMP_DIR/BACKUP_INFO.txt"

(
    cd "$TEMP_DIR"
    find . -type f ! -name SHA256SUMS -print0 \
        | sort -z \
        | xargs -0 sha256sum \
        > SHA256SUMS

    sha256sum --quiet -c SHA256SUMS
)

mv "$TEMP_DIR" "$FINAL_DIR"

find "$BACKUP_ROOT" \
    -mindepth 1 \
    -maxdepth 1 \
    -type d \
    -name '20??-??-??_??-??-??' \
    -mtime +"$RETENTION_DAYS" \
    -print \
    -exec rm -rf -- {} +

echo "BACKUP_OK: $FINAL_DIR"
