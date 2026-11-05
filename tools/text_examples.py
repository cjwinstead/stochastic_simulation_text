#!/usr/bin/env python3
"""Extract the Julia code blocks from the text so they can be run as tests.

Usage: text_examples.py OUTDIR markdown/*.md

Writes one file per ```julia block, named chN_LNNN.jl after the chapter file
and the line where the block starts, and prints the file names. Each block
must run on its own, as a reader would run it.
"""

import re
import sys
from pathlib import Path

BLOCK = re.compile(r"^```\s*\{?\.?julia\b[^\n]*\n(.*?)^```", re.S | re.M | re.I)


def main(argv):
    if len(argv) < 3:
        print(__doc__)
        return 2
    out = Path(argv[1])
    out.mkdir(parents=True, exist_ok=True)
    for old in out.glob("ch*_L*.jl"):
        old.unlink()
    for path in argv[2:]:
        text = Path(path).read_text(encoding="utf-8")
        chapter = Path(path).name.split("_")[0]
        for m in BLOCK.finditer(text):
            line = text.count("\n", 0, m.start()) + 1
            name = f"ch{chapter}_L{line:04d}.jl"
            (out / name).write_text(m.group(1), encoding="utf-8")
            print(name)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
