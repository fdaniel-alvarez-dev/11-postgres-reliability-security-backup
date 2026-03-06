from __future__ import annotations

import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]


class TestRepoDemoMode(unittest.TestCase):
    def test_backup_verification_runbook_present(self) -> None:
        p = (REPO_ROOT / "docs" / "runbooks" / "backup-verification.md").read_text(encoding="utf-8")
        self.assertIn("Backup verification", p)

    def test_backup_verify_script_present(self) -> None:
        self.assertTrue((REPO_ROOT / "scripts" / "backup_verify.sh").exists())

