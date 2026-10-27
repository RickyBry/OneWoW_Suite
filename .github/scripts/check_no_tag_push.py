"""Fail if any workflow pushes, moves or deletes a git tag.

Tag pushes make GitHub's Discord webhook post every commit since the old tag as new.
"""
import pathlib
import re
import sys

PATTERNS = [
    (r"git\s+push\b[^\n]*--(tags|follow-tags|mirror)", "git push of tags"),
    (r"git\s+push\b[^\n]*refs/tags", "git push to refs/tags"),
    (r"git\s+push\b[^\n]*\s:[\w./-]+", "git push delete ref"),
    (r"git\s+tag\b[^\n]*\s(-f|--force|-d|--delete)\b", "git tag move/delete"),
    (r"git/refs/tags", "tag ref update via API"),
    (r"gh\s+release\s+(create|delete)\b", "release recreate (creates or drops the tag)"),
    (r"--cleanup-tag", "release tag cleanup"),
    (r"(create|update|delete)[-_]?ref\b", "ref update action/API"),
]

bad = []
for f in sorted(pathlib.Path(".github/workflows").glob("*.y*ml")):
    for n, line in enumerate(f.read_text(encoding="utf-8").splitlines(), 1):
        if line.lstrip().startswith("#"):
            continue
        for rx, why in PATTERNS:
            if re.search(rx, line):
                bad.append(f"{f}:{n}: {why}: {line.strip()}")
if bad:
    print("Workflows must not push, move or delete tags:")
    print("\n".join(bad))
    sys.exit(1)
print("No tag pushes in workflows.")
