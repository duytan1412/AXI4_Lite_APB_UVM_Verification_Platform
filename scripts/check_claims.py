#!/usr/bin/env python3
from pathlib import Path
import re
import sys

RISKY = re.compile(r"\b(full coverage|sign[- ]off|production[- ]ready|industry[- ]grade|100% coverage)\b", re.I)
ALLOW_MARKERS = ("honest limitation", "forbidden", "without evidence", "do not claim", "not claim")
DOCS = [p for name in ("README.md", "PORTFOLIO.md") for p in [Path(name)] if p.exists()]
if Path("docs").exists():
    DOCS += [p for p in sorted(Path("docs").glob("*.md")) if p.name != "evidence_policy.md"]
failures = []
for path in DOCS:
    for lineno, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
        if RISKY.search(line) and not any(marker in line.lower() for marker in ALLOW_MARKERS):
            failures.append(f"{path}:{lineno}: risky claim needs evidence or weaker wording: {line.strip()}")
if failures:
    print("\n".join(failures))
    sys.exit(1)
print(f"claim check passed ({len(DOCS)} docs scanned)")
