# Backup verification drill

Backups are only valuable if you can restore them predictably. This drill makes that proof explicit.

## What this drill does

1) Seeds a tiny amount of deterministic demo data
2) Creates a logical backup artifact under `artifacts/backups/`
3) Restores the backup into a temporary verification database
4) Runs a post-restore query to confirm the data exists
5) Drops the verification database

## Run it locally

```bash
make up
make seed
make backup
make backup-verify
```

## What “good” looks like

- Verification succeeds repeatedly without manual steps.
- Failures are actionable (missing services, missing backup artifact, SQL errors).
- The verification database is always removed after the check.

