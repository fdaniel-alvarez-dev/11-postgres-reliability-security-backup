#!/usr/bin/env bash
set -euo pipefail

primary_id="$(docker compose ps -q postgres-primary)"
if [[ -z "${primary_id}" ]]; then
  echo "Service 'postgres-primary' is not running. Start the lab first: make up"
  exit 1
fi

echo "Seeding demo data used for backup verification..."
docker exec -i "${primary_id}" psql -U app -d appdb -v ON_ERROR_STOP=1 <<'SQL'
create table if not exists public.drill_items (
  id bigserial primary key,
  note text not null,
  created_at timestamptz not null default now()
);

insert into public.drill_items (note)
values ('backup-drill'), ('restore-drill')
on conflict do nothing;
SQL

docker exec -i "${primary_id}" psql -U app -d appdb -tA -v ON_ERROR_STOP=1 -c "select count(*) from public.drill_items;"

