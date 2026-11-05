#!/usr/bin/env python3
"""Check each chapter's Key Terms against the terms defined in its text.

Convention: a term is defined where it first appears in **bold**, and the
chapter's "## Key Terms" section has one entry for it, under the same name,
in the order the terms are defined. Bold is used for nothing else; use
*italics* for emphasis.

A Key Terms entry is a definition-list item:

    Term Name $optional \\cdot math$

    : Definition.

An entry may name synonyms that are bolded in the text, separated by commas:
"Expectation, Expected Value $\\mathcal{E}_\\mu(\\mathbf{X})$".

Names are compared case-insensitively, ignoring math, markup, hyphens, and a
plural "s". Problems reported:

  missing    a bold term with no Key Terms entry
  extra      an entry whose term is never bolded in the chapter
  order      entries not in the order their terms are defined
  repeated   a term bolded more than once in the book
  no-section a chapter with bold terms but no Key Terms section

Usage: check_keyterms.py markdown/*.md      (exit status 1 if any problem)
"""

import re
import sys
from pathlib import Path

KEYTERMS = re.compile(r"^#{2,}\s+Key Terms\b.*$", re.M)
BOLD = re.compile(r"\*\*(?=\S)(.+?)(?<=\S)\*\*", re.S)
HEADING = re.compile(r"^#{2,}\s+(.*?)\s*(\{#[^}]*\})?\s*$", re.M)


def strip_code(text):
    """Blank out fenced and inline code so their contents are not scanned,
    keeping line numbers intact."""
    text = re.sub(r"^```.*?^```", lambda m: "\n" * m.group(0).count("\n"), text, flags=re.S | re.M)
    return re.sub(r"`[^`\n]*`", "", text)


def normalize(name):
    name = re.sub(r"\$[^$]*\$", " ", name)                 # math
    name = re.sub(r"\[([^\]]*)\]\{[^}]*\}", r"\1", name)   # [text]{.draft}
    name = re.sub(r"\([^)]*\)", " ", name)                  # parenthetical
    name = re.sub(r"[*_`\"“”'’]", "", name)
    name = re.sub(r"[-–—/]", " ", name)
    words = re.sub(r"[^\w\s]", " ", name.lower()).split()
    words = [w[:-1] if len(w) > 3 and w.endswith("s") and not w.endswith("ss") else w
             for w in words]
    return " ".join(words)


def bold_terms(body):
    """(normalized, display, line) for each bold term in order of appearance."""
    out = []
    for m in BOLD.finditer(body):
        display = re.sub(r"\s+", " ", m.group(1)).strip()
        key = normalize(display)
        if key:
            out.append((key, display, body.count("\n", 0, m.start()) + 1))
    return out


def split_names(line):
    """Split an entry line into its comma-separated names, ignoring commas in math."""
    parts, depth, cur = [], False, ""
    for ch in line:
        if ch == "$":
            depth = not depth
        if ch == "," and not depth:
            parts.append(cur); cur = ""
        else:
            cur += ch
    parts.append(cur)
    return [k for k in (normalize(p) for p in parts) if k]


def entries(section, offset):
    """(names, display, line) for each definition-list entry."""
    lines = section.split("\n")
    out = []
    for i, line in enumerate(lines):
        if not line.strip() or line[0] in ": \t#" or line.startswith("\\"):
            continue
        j = i + 1
        while j < len(lines) and not lines[j].strip():
            j += 1
        if j < len(lines) and lines[j].startswith(":"):
            out.append((split_names(line), line.strip(), offset + i))
    return out


def check(paths):
    problems = []
    first_bold = {}                                   # key -> (file, line)
    for path in paths:
        text = Path(path).read_text(encoding="utf-8")
        name = Path(path).name
        m = KEYTERMS.search(text)
        body = strip_code(text[: m.start()] if m else text)
        terms = bold_terms(body)

        # repeated bold, across the whole book
        seen_here = []
        for key, display, line in terms:
            if key in first_bold:
                f, l = first_bold[key]
                problems.append(f"{name}:{line}: repeated   **{display}** (defined at {f}:{l}); "
                                "use italics or plain text here")
            else:
                first_bold[key] = (name, line)
                seen_here.append((key, display, line))

        if not m:
            if seen_here:
                problems.append(f"{name}: no-section  {len(seen_here)} bold terms but no "
                                "'## Key Terms' section")
            continue

        offset = text.count("\n", 0, m.start()) + 1
        ents = entries(text[m.start():], offset)
        term_keys = [k for k, _, _ in seen_here]
        covered = {k for names, _, _ in ents for k in names}

        for key, display, line in seen_here:
            if key not in covered:
                problems.append(f"{name}:{line}: missing    **{display}** has no Key Terms entry")
        placed = []                                     # (first term position, entry)
        for names, display, line in ents:
            pos = [term_keys.index(k) for k in names if k in term_keys]
            if not pos:
                where = next((first_bold[k] for k in names if k in first_bold), None)
                hint = f" (bolded in {where[0]})" if where and where[0] != name else ""
                problems.append(f"{name}:{line}: extra      entry '{display}' is not bolded "
                                f"in this chapter{hint}")
            else:
                placed.append((min(pos), display, line))

        # order: entries should follow the order their terms are defined
        for (want, (got_pos, got_disp, line)) in zip(sorted(placed), placed):
            if want[0] != got_pos:
                problems.append(f"{name}:{line}: order      entry '{got_disp}' is out of place; "
                                f"'{want[1]}' should come here (text order)")
                break
    return problems


def main(argv):
    paths = sorted(argv[1:])
    if not paths:
        print(__doc__)
        return 2
    problems = check(paths)
    for p in problems:
        print(p)
    if problems:
        print(f"{len(problems)} problem(s)")
        return 1
    print(f"Key Terms consistent in {len(paths)} chapter(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
