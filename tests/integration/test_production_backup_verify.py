from __future__ import annotations

import subprocess
import time
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]


def _run(cmd: list[str], *, timeout_s: int = 120) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        cmd,
        cwd=str(REPO_ROOT),
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        timeout=timeout_s,
    )


class TestProductionBackupVerify(unittest.TestCase):
    def test_backup_and_verify(self) -> None:
        try:
            _run(["docker", "compose", "up", "-d", "--build"], timeout_s=600)

            deadline = time.time() + 90
            while True:
                try:
                    _run(
                        ["docker", "compose", "exec", "-T", "postgres-primary", "psql", "-U", "app", "-d", "appdb", "-c", "select 1;"],
                        timeout_s=30,
                    )
                    break
                except Exception:
                    if time.time() > deadline:
                        raise
                    time.sleep(2)

            _run(["make", "seed"], timeout_s=60)
            _run(["make", "backup"], timeout_s=120)
            _run(["make", "backup-verify"], timeout_s=180)
        finally:
            subprocess.run(["docker", "compose", "down", "-v"], cwd=str(REPO_ROOT), check=False)

