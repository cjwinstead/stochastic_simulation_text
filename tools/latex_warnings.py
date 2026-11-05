#!/usr/bin/env python3
"""Summarize the warnings in a LaTeX log.

Usage: latex_warnings.py BUILD.log [--strict]

Reports, each with the source file being read at the time:

  missing character   a glyph the font lacks (font "nullfont" means a stray
                      character where no font is selected, usually in a figure)
  overfull box        text wider than its space (more than 1pt)
  undefined reference a cross-reference with no label
  other               remaining LaTeX and package warnings

Prints "no warnings" when the log is clean. Exit status is 0, or 1 with
--strict when anything is reported.
"""

import re
import sys
from collections import Counter
from pathlib import Path

FILE_OPEN = re.compile(r"\((\.{0,2}/?[\w./-]+\.(?:tex|sty|cls|def|cfg|fd|clo))")
MISSING = re.compile(r"Missing character: There is no (.+?) (?:\((U\+[0-9A-F]+|\"[0-9A-F]+)\) )?in font (.+?)!")
OVERFULL = re.compile(r"Overfull \\[hv]box \(([\d.]+)pt too (?:wide|high)\) (.*)")
UNDEF_REF = re.compile(r"LaTeX Warning: Reference `([^']+)' on page (\d+) undefined")
OTHER = re.compile(r"((?:LaTeX|Package \w+|Class \w+) Warning: .*)")
# Known, harmless messages. mathtools asks to be loaded before unicode-math,
# but pandoc's default template loads unicode-math before the book's
# preamble; the order has no visible effect on the text. A document with no
# captioned tables (the notebook review copy) leaves \captionsetup[table] unused.
IGNORE = re.compile(r"Label\(s\) may have changed|There were undefined references|"
                    r"Font shape .* undefined|Size substitutions|Some font shapes were not available|"
                    r"mathtools Warning: For best results, please load mathtools \*before\*|"
                    r"Unused \\captionsetup\[table\]")


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    strict = "--strict" in argv
    text = Path(argv[1]).read_text(encoding="utf-8", errors="replace")
    # TeX wraps log lines at 79 characters; rejoin them.
    text = re.sub(r"(?m)^(.{79})\n", r"\1", text)

    current = "(preamble)"
    missing, overfull, undefined, other = Counter(), [], Counter(), Counter()
    for line in text.split("\n"):
        for m in FILE_OPEN.finditer(line):
            name = m.group(1)
            if not name.endswith((".sty", ".cls", ".def", ".cfg", ".fd", ".clo")):
                current = name.lstrip("./")
        if m := MISSING.search(line):
            missing[(m.group(1), m.group(2) or "", m.group(3), current)] += 1
        elif m := OVERFULL.search(line):
            if float(m.group(1)) > 1.0:
                overfull.append((float(m.group(1)), m.group(2).strip(), current))
        elif m := UNDEF_REF.search(line):
            undefined[m.group(1)] += 1
        elif (m := OTHER.search(line)) and not IGNORE.search(line):
            other[m.group(1).strip()] += 1

    found = 0
    if missing:
        print("Missing characters:")
        for (ch, code, font, where), n in sorted(missing.items(), key=lambda kv: kv[0][3]):
            print(f"  {n:3d} x  '{ch}' {code} in font {font}   [{where}]")
        found += len(missing)
    if overfull:
        print("Overfull boxes:")
        for amount, what, where in overfull:
            print(f"  {amount:6.1f}pt  {what[:60]}   [{where}]")
        found += len(overfull)
    if undefined:
        print("Undefined references:")
        for ref, n in sorted(undefined.items()):
            print(f"  {ref} ({n}x)")
        found += len(undefined)
    if other:
        print("Other warnings:")
        for msg, n in sorted(other.items()):
            print(f"  {n:3d} x  {msg[:110]}")
        found += len(other)
    if not found:
        print("no warnings")
    return 1 if (strict and found) else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
