.PHONY: demo up down logs seed backup restore backup-verify check test test-demo test-production

demo: up check seed backup backup-verify
	@echo "Demo complete. Try: make logs"

up:
	docker compose up -d --build

down:
	docker compose down -v

logs:
	docker compose logs -f --tail=200

check:
	bash scripts/check_replication.sh

seed:
	bash scripts/seed_demo_data.sh

backup:
	bash scripts/backup.sh

restore:
	bash scripts/restore.sh

backup-verify:
	bash scripts/backup_verify.sh

test: test-demo

test-demo:
	@TEST_MODE=demo python3 tests/run_tests.py

test-production:
	@TEST_MODE=production python3 tests/run_tests.py
