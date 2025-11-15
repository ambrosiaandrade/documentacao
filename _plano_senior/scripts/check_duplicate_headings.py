#!/usr/bin/env python3
"""Detect duplicate Markdown headings across repository files.
Usage: python scripts/check_duplicate_headings.py [root(optional)]
Exits non-zero if duplicates found.
"""
from __future__ import annotations
import os, sys, re, collections

ROOT = sys.argv[1] if len(sys.argv) > 1 else os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IGNORE_DIRS = {'.git', 'out', 'node_modules'}
EXT = {'.md'}
HEADING_RE = re.compile(r'^(#+)\s+(.*)$')

Occurrence = collections.namedtuple('Occurrence', 'file line text level')

headings_map: dict[str, list[Occurrence]] = {}

for dirpath, dirnames, filenames in os.walk(ROOT):
    dirnames[:] = [d for d in dirnames if d not in IGNORE_DIRS]
    for fname in filenames:
        if os.path.splitext(fname)[1].lower() in EXT:
            fpath = os.path.join(dirpath, fname)
            try:
                with open(fpath, 'r', encoding='utf-8') as f:
                    for i, line in enumerate(f, 1):
                        m = HEADING_RE.match(line.rstrip())
                        if not m:
                            continue
                        level = len(m.group(1))
                        text = m.group(2).strip()
                        # normalize text for comparison (case-insensitive)
                        key = text.lower()
                        headings_map.setdefault(key, []).append(Occurrence(fpath, i, text, level))
            except Exception as e:
                print(f"WARN: cannot read {fpath}: {e}", file=sys.stderr)

# Detect duplicates (same text repeated >1 across any files OR >1 times in same file at same level)
problems = []
for key, occs in headings_map.items():
    if len(occs) > 1:
        # group by file+level
        file_level = collections.defaultdict(list)
        for o in occs:
            file_level[(o.file, o.level)].append(o)
        multi_file = len({o.file for o in occs}) > 1
        same_file_dups = {fl: grp for fl, grp in file_level.items() if len(grp) > 1}
        if multi_file or same_file_dups:
            problems.append((key, occs))

if problems:
    print("Duplicate headings detected:\n")
    for key, occs in problems:
        print(f"-- '{occs[0].text}'")
        for o in occs:
            print(f"   {o.file}:{o.line} (level {o.level})")
        print()
    print(f"Total duplicate heading texts: {len(problems)}")
    sys.exit(1)
else:
    print("No duplicate headings found.")
