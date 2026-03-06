#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
latest="$(ls -1t "${repo_root}"/artifacts/backups/*.sql 2>/dev/null | head -n 1 || true)"
if [[ -z "${latest}" ]]; then
  echo "No backups found under artifacts/backups/. Run: make backup"
  exit 1
fi

primary_id="$(docker compose ps -q postgres-primary)"
if [[ -z "${primary_id}" ]]; then
  echo "Service 'postgres-primary' is not running. Start the lab first: make up"
  exit 1
fi

verify_db="appdb_verify"
echo "Verifying backup by restoring into '${verify_db}' from: ${latest}"

docker exec -i "${primary_id}" psql -U app -d postgres -v ON_ERROR_STOP=1 -c "drop database if exists ${verify_db};"
docker exec -i "${primary_id}" psql -U app -d postgres -v ON_ERROR_STOP=1 -c "create database ${verify_db};"

docker exec -i "${primary_id}" psql -U app -d "${verify_db}" -v ON_ERROR_STOP=1 < "${latest}"

echo "Running post-restore checks..."
docker exec -i "${primary_id}" psql -U app -d "${verify_db}" -tA -v ON_ERROR_STOP=1 -c "select count(*) from public.drill_items;" | grep -Eq '^[0-9]+$'

docker exec -i "${primary_id}" psql -U app -d postgres -v ON_ERROR_STOP=1 -c "drop database ${verify_db};"
echo "Backup verification OK."

