#!/usr/bin/env python3
"""Split notebook solutions into a private file, or merge them back in.

Notebooks are Jupytext percent-format .jl files. A solution, or a block of
hidden tests, sits between marker lines:

    #@solution p1
    L = logpdf.(μ, y) .- logpdf.(ν, y)
    #@end

    #@hidden-tests p1
    @assert ...
    #@end

A key is unique among regions of the same kind, so a problem's solution and
its hidden tests can share one ("p1"). In a markdown cell the markers carry the
cell's usual "# " prefix ("# #@solution reflection").

A notebook exists in two forms:

  full    regions filled in; what the author writes and tests
  public  regions empty (marker lines only); what goes in the public repo

The private repo holds one solutions file per notebook, NAME.solutions.jl,
in the same marker format.

Commands:

  split  FULL.jl  --public OUT.jl --solutions OUT.solutions.jl
      Empty every region of FULL into OUT.jl and write the region bodies to
      the solutions file. nbgrader delimiters (### BEGIN SOLUTION ...) are
      accepted too, keyed by the cell's grade_id, so older drafts import.

  merge  PUBLIC.jl  SOLUTIONS.jl  -o FULL.jl  [--nbgrader]
      Fill the regions of PUBLIC from the solutions file. With --nbgrader the
      markers become nbgrader's ### BEGIN/END SOLUTION and HIDDEN TESTS
      delimiters, ready for Jupytext and the hub.

  check  FILE.jl ...
      Exit with status 1 if any file contains a non-empty region or nbgrader
      solution delimiters, i.e. if it is not safe to publish.
"""

import argparse
import re
import sys
from pathlib import Path

KINDS = ("solution", "hidden-tests")
START = re.compile(r"^(?P<prefix>\s*(?:#\s)?)#@(?P<kind>solution|hidden-tests)\s+(?P<key>[\w.-]+)\s*$")
END = re.compile(r"^\s*(?:#\s)?#@end\s*$")
NOTEBOOK = re.compile(r"^#@notebook\s+(?P<name>\S+)\s*$")

NB_BEGIN = {"### BEGIN SOLUTION": "solution", "### BEGIN HIDDEN TESTS": "hidden-tests"}
NB_END = {"### END SOLUTION": "solution", "### END HIDDEN TESTS": "hidden-tests"}
NB_DELIMS = {"solution": ("### BEGIN SOLUTION", "### END SOLUTION"),
             "hidden-tests": ("### BEGIN HIDDEN TESTS", "### END HIDDEN TESTS")}
GRADE_ID = re.compile(r'^# %%.*"grade_id"\s*:\s*"(?P<id>[^"]+)"')


class MarkerError(Exception):
    pass


def parse_regions(lines, path):
    """Yield (start, end, kind, key, prefix) for each region, end exclusive of the #@end line."""
    regions, open_region, seen = [], None, set()
    for i, line in enumerate(lines):
        m = START.match(line)
        if m:
            if open_region:
                raise MarkerError(f"{path}:{i + 1}: region opened inside region '{open_region[2]}'")
            key = m["key"]
            if (m["kind"], key) in seen:
                raise MarkerError(f"{path}:{i + 1}: duplicate {m['kind']} key '{key}'")
            seen.add((m["kind"], key))
            open_region = (i, m["kind"], key, m["prefix"])
        elif END.match(line):
            if not open_region:
                raise MarkerError(f"{path}:{i + 1}: #@end without an open region")
            s, kind, key, prefix = open_region
            regions.append((s, i, kind, key, prefix))
            open_region = None
    if open_region:
        raise MarkerError(f"{path}:{open_region[0] + 1}: region '{open_region[2]}' is never closed")
    return regions


def nbgrader_to_markers(lines, path):
    """Rewrite nbgrader delimiters as #@ markers, keyed by the enclosing cell's grade_id."""
    out, grade_id, counts, open_kind = [], None, {}, None
    for i, line in enumerate(lines):
        g = GRADE_ID.match(line)
        if g:
            grade_id = g["id"]
        if line.startswith("# %%") and not g:
            grade_id = None
        stripped = line.strip()
        md = False
        if stripped.startswith("# ###"):
            stripped, md = stripped[2:], True
        if stripped in NB_BEGIN:
            if open_kind:
                raise MarkerError(f"{path}:{i + 1}: nested nbgrader delimiters")
            open_kind = NB_BEGIN[stripped]
            base = grade_id or f"cell{i + 1}"
            base = re.sub(r"_(solution|tests)$", "", base)
            n = counts.get((base, open_kind), 0)
            counts[(base, open_kind)] = n + 1
            key = base if n == 0 else f"{base}.{n + 1}"
            indent = line[: len(line) - len(line.lstrip())] + ("# " if md else "")
            out.append(f"{indent}#@{open_kind} {key}")
        elif stripped in NB_END:
            if open_kind != NB_END[stripped]:
                raise MarkerError(f"{path}:{i + 1}: unmatched {stripped}")
            indent = line[: len(line) - len(line.lstrip())] + ("# " if md else "")
            out.append(f"{indent}#@end")
            open_kind = None
        else:
            out.append(line)
    if open_kind:
        raise MarkerError(f"{path}: unclosed nbgrader {open_kind} block")
    return out


def read_lines(path):
    return Path(path).read_text(encoding="utf-8").split("\n")


def write_lines(path, lines):
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    Path(path).write_text("\n".join(lines), encoding="utf-8")


def read_solutions(path):
    lines = read_lines(path)
    blocks = {}
    for s, e, kind, key, _ in parse_regions(lines, path):
        blocks[(kind, key)] = lines[s + 1:e]
    names = [m["name"] for m in map(NOTEBOOK.match, lines) if m]
    return blocks, (names[0] if names else None)


def cmd_split(args):
    lines = nbgrader_to_markers(read_lines(args.full), args.full)
    regions = parse_regions(lines, args.full)
    public, blocks, last = [], [], 0
    for s, e, kind, key, _ in regions:
        public.extend(lines[last:s + 1])      # up to and including the start marker
        public.append(lines[e])               # the #@end marker
        blocks.append((kind, key, lines[s + 1:e]))
        last = e + 1
    public.extend(lines[last:])
    name = Path(args.full).stem
    sol = [f"#@notebook {name}",
           "# Solutions and hidden tests. Private: do not publish.", ""]
    for kind, key, body in blocks:
        sol += [f"#@{kind} {key}", *body, "#@end", ""]
    write_lines(args.public, public)
    write_lines(args.solutions, sol)
    print(f"split {args.full}: {len(blocks)} regions -> {args.public}, {args.solutions}")


def cmd_merge(args):
    lines = read_lines(args.public)
    # A notebook with no problems needs no solutions file.
    blocks, name = read_solutions(args.solutions) if Path(args.solutions).exists() else ({}, None)
    stem = Path(args.public).stem
    if name and name != stem:
        raise MarkerError(f"{args.solutions} is for notebook '{name}', not '{stem}'")
    regions = parse_regions(lines, args.public)
    out, used, last = [], set(), 0
    for s, e, kind, key, prefix in regions:
        if e != s + 1:
            raise MarkerError(f"{args.public}:{s + 1}: region '{key}' is not empty; is this a public file?")
        if (kind, key) not in blocks:
            raise MarkerError(f"{args.solutions}: no {kind} block '{key}' (needed by {args.public}:{s + 1})")
        body = blocks[(kind, key)]
        used.add((kind, key))
        out.extend(lines[last:s])
        if args.nbgrader and prefix.strip() == "#":
            # Markdown cell: nbgrader treats the whole cell as the answer.
            out += body
        elif args.nbgrader:
            begin, end = NB_DELIMS[kind]
            out += [prefix + begin, *body, prefix + end]
        else:
            out += [lines[s], *body, lines[e]]
        last = e + 1
    out.extend(lines[last:])
    unused = sorted(set(blocks) - used)
    if unused:
        names = ", ".join(f"{k} {key}" for k, key in unused)
        raise MarkerError(f"{args.solutions}: blocks not used by {args.public}: {names}")
    write_lines(args.output, out)
    print(f"merged {args.public} + {args.solutions}: {len(regions)} regions -> {args.output}")


def cmd_check(args):
    bad = 0
    for path in args.files:
        lines = read_lines(path)
        for line_no, line in enumerate(lines, 1):
            t = line.strip()
            if t in NB_BEGIN or (t.startswith("# ") and t[2:] in NB_BEGIN):
                print(f"{path}:{line_no}: nbgrader delimiter in a public file")
                bad += 1
        try:
            regions = parse_regions(lines, path)
        except MarkerError as err:
            print(err)
            bad += 1
            continue
        for s, e, kind, key, _ in regions:
            if e != s + 1:
                print(f"{path}:{s + 1}: {kind} '{key}' has content")
                bad += 1
    if bad:
        print(f"{bad} problem(s): not safe to publish")
        return 1
    print(f"{len(args.files)} file(s) safe to publish")
    return 0


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    sub = p.add_subparsers(dest="command", required=True)
    s = sub.add_parser("split", help="move solutions out of a full notebook")
    s.add_argument("full")
    s.add_argument("--public", required=True)
    s.add_argument("--solutions", required=True)
    m = sub.add_parser("merge", help="put solutions back into a public notebook")
    m.add_argument("public")
    m.add_argument("solutions")
    m.add_argument("-o", "--output", required=True)
    m.add_argument("--nbgrader", action="store_true", help="emit nbgrader delimiters")
    c = sub.add_parser("check", help="fail if any file contains solutions")
    c.add_argument("files", nargs="+")
    args = p.parse_args(argv)
    try:
        if args.command == "split":
            cmd_split(args)
        elif args.command == "merge":
            cmd_merge(args)
        else:
            return cmd_check(args)
    except MarkerError as err:
        print(f"error: {err}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
