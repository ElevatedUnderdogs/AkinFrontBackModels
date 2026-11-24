#!/usr/bin/env python3
"""Warns (never fails) about model changes that can break older apps or servers.

Usage: diff_warnings.py <base-ref>     e.g. diff_warnings.py origin/main

Checks the Sources diff for:
  - a new non-optional stored property with no default in a Codable type
  - a removed or renamed stored property in a Codable type
  - a new case in a Codable enum
  - a removed or renamed contract (its static var is the route path)
Prints GitHub `::warning` annotations and a summary.
"""
import os, re, subprocess, sys

TYPE_DECL = re.compile(r"\b(struct|class|enum|actor|extension)\s+([A-Za-z_][\w.]*)")
STORED = re.compile(r"^\s*(?:@\w+(?:\([^)]*\))?\s+)*(?:(?:public|internal|private|fileprivate|package|open)(?:\(set\))?\s+)*(let|var)\s+(\w+)\s*:\s*([^={]+?)\s*(=.*)?$")
ENUM_CASE = re.compile(r"^\s*(?:indirect\s+)?case\s+(.+)$")
CONTRACT = re.compile(r"^\s*public\s+static\s+var\s+(\w+)\s*:\s*Self\b")
CODABLE = re.compile(r"\b(Codable|Decodable|Encodable)\b")


def git(*args):
    return subprocess.run(["git", *args], capture_output=True, text=True).stdout


def code(line):
    return re.sub(r'"(?:\\.|[^"\\])*"', '""', line.split("//")[0])


def enclosing(lines, index):
    """The declaration line of the scope that directly holds lines[index], or None."""
    depth = 0
    for i in range(index - 1, -1, -1):
        c = code(lines[i])
        depth += c.count("}") - c.count("{")
        if depth < 0:
            # A declaration can wrap; read back to the line that names the type.
            for j in range(i, max(i - 4, -1), -1):
                m = TYPE_DECL.search(code(lines[j]))
                if m:
                    return m.group(1), m.group(2), " ".join(code(l) for l in lines[j:i + 1])
                if re.search(r"\b(func|init|var|let|get|set|if|for|switch|case|guard|while)\b", code(lines[j])):
                    break
            return None
    return None


def codable_names(texts):
    names = set()
    for text in texts:
        for m in re.finditer(r"\b(?:struct|class|enum|actor|extension)\s+(\w+)[^{]*?:\s*([^{]*)\{", text):
            if CODABLE.search(m.group(2)):
                names.add(m.group(1))
    return names


def contract_aliases(texts):
    return {m.group(1) for t in texts for m in re.finditer(r"typealias\s+(\w+)\s*=\s*Request<", t)}


def is_codable(decl, codable):
    kind, name, header = decl
    return CODABLE.search(header) is not None or name.split(".")[-1] in codable


def parse_hunks(diff):
    """{path: [(old_start, old_lines[], new_start, new_lines[])]} from a -U0 diff."""
    files, path = {}, None
    old_no = new_no = 0
    for line in diff.splitlines():
        if line.startswith("+++ "):
            path = None if line[4:] == "/dev/null" else line[6:]
        elif line.startswith("--- "):
            old_path = None if line[4:] == "/dev/null" else line[6:]
        elif line.startswith("@@"):
            m = re.match(r"@@ -(\d+)(?:,\d+)? \+(\d+)", line)
            old_no, new_no = int(m.group(1)), int(m.group(2))
            files.setdefault(path or old_path, []).append(([], []))
        elif line.startswith("-") and files:
            files[path or old_path][-1][0].append((old_no, line[1:])); old_no += 1
        elif line.startswith("+") and files:
            files[path or old_path][-1][1].append((new_no, line[1:])); new_no += 1
    return files


def main():
    base = sys.argv[1] if len(sys.argv) > 1 else "origin/main"
    merge_base = git("merge-base", base, "HEAD").strip() or base
    diff = git("diff", "-U0", merge_base, "HEAD", "--", "Sources")
    paths = [p for p in parse_hunks(diff)]
    new_texts = {p: git("show", f"HEAD:{p}") for p in paths}
    old_texts = {p: git("show", f"{merge_base}:{p}") for p in paths}
    all_new = git("grep", "-h", "-E", "Codable|Decodable|Encodable|typealias", "HEAD", "--", "Sources")
    all_old = git("grep", "-h", "-E", "Codable|Decodable|Encodable|typealias", merge_base, "--", "Sources")
    codable = codable_names([all_new, all_old])
    aliases = contract_aliases([all_new, all_old])

    warnings = []

    def warn(path, line, title, message):
        warnings.append((path, line, title, message))

    for path, hunks in parse_hunks(diff).items():
        new_lines = new_texts[path].splitlines()
        old_lines = old_texts[path].splitlines()
        for removed, added in hunks:
            added_props = {}
            for no, text in added:
                m = STORED.match(code(text))
                if m and "static" not in text:
                    added_props[m.group(2)] = (no, m)
            added_contracts = {CONTRACT.match(t).group(1) for _, t in added if CONTRACT.match(t)}
            anchor = added[0][0] if added else max(1, min(len(new_lines), removed[0][0] if removed else 1))

            for no, text in removed:
                if CONTRACT.match(text):
                    decl = enclosing(old_lines, no - 1)
                    name = CONTRACT.match(text).group(1)
                    if decl and decl[1] in aliases and name not in added_contracts:
                        renamed = f" (renamed to {', '.join(sorted(added_contracts))}?)" if added_contracts else ""
                        warn(path, anchor, "Contract removed or renamed",
                             f"`{decl[1]}.{name}` is gone{renamed}. The static var name is the route path, "
                             "so older apps still calling it will get 404s.")
                    continue
                m = STORED.match(code(text))
                if not m or "static" in text or "{" in code(text):
                    continue
                decl = enclosing(old_lines, no - 1)
                if decl and decl[0] != "enum" and is_codable(decl, codable) and m.group(2) not in added_props:
                    warn(path, anchor, "Property removed or renamed",
                         f"`{decl[1]}.{m.group(2)}` was removed or renamed. Older apps or servers that still "
                         "send or expect this key will fail to decode or lose the value.")

            for name, (no, m) in added_props.items():
                text = code(new_lines[no - 1]) if no - 1 < len(new_lines) else ""
                kind, type_, default = m.group(1), m.group(3).strip(), m.group(4)
                if "{" in text or type_.endswith("?") or default or type_.startswith("Optional<"):
                    continue
                decl = enclosing(new_lines, no - 1)
                if decl and decl[0] != "enum" and is_codable(decl, codable):
                    warn(path, no, "New required property",
                         f"`{decl[1]}.{name}: {type_}` is required with no default. JSON from older apps or "
                         f"servers won't have it, so decoding fails. Make it `{type_}?` or decode it with a default.")

            for no, text in added:
                m = ENUM_CASE.match(code(text))
                if not m:
                    continue
                decl = enclosing(new_lines, no - 1)
                if not decl or decl[0] != "enum" or decl[1] == "CodingKeys" or not is_codable(decl, codable):
                    continue
                old_cases = {c.strip() for _, t in removed if ENUM_CASE.match(code(t))
                             for c in ENUM_CASE.match(code(t)).group(1).split(",")}
                new_cases = [c.strip() for c in m.group(1).split(",") if c.strip() not in old_cases]
                if new_cases:
                    warn(path, no, "New enum case",
                         f"`{decl[1]}` gained `{', '.join(new_cases)}`. Older apps that receive it fail to decode "
                         "unless they have a fallback (e.g. an `unknown` case).")

    for path, line, title, message in warnings:
        print(f"::warning file={path},line={line},title={title}::{message}")
    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    report = [f"### Wire compatibility: {len(warnings)} warning(s)", ""]
    report += [f"- **{t}** `{p}:{l}`: {m}" for p, l, t, m in warnings] or ["No risky model changes found."]
    if summary:
        with open(summary, "a") as f:
            f.write("\n".join(report) + "\n")
    print("\n".join(report))


if __name__ == "__main__":
    try:
        main()
    except Exception as error:  # A broken check must never block a PR.
        print(f"::warning title=Wire compatibility check crashed::{error}")
    sys.exit(0)
