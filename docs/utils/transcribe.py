#!/usr/bin/env python

import argparse
import os
from pathlib import Path
import re
import sys
from typing import Sequence, cast

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from fetch_discourse_md import fetch as md_fetch


# from fetch_discourse_md import fetch as md_fetch

CMDRUN_RE = r"<!--\s?cmdrun\s+fetch_discourse_md\.py\s+\"(.*)\"\s*-->"


def debug(*o, **kargs):
    if os.getenv("DEBUG") in ["1", "on", "yes", "true", "TRUE", "True"]:
        return print("[DEBUG]:", *(map(str, o)), file=sys.stderr, **kargs)


def transcribe(execute=False, files_with_cmdrun: Sequence[Path] = []):

    def handler(match: re.Match[str]) -> str:
        url = match.group(1)
        res = md_fetch(url) or ""
        if (s := len(res)) > 0:
            debug(" " * 4, "Fetched", s, "characters")
        return res

    for md_file in files_with_cmdrun:
        debug(md_file)
        # Get the discourse url
        with open(md_file) as f:
            contents = f.read()
        new_content = re.sub(CMDRUN_RE, handler, contents)
        if new_content != contents:
            # Report we got a file replaced
            if m := re.search(CMDRUN_RE, contents):
                print(f"{md_file}\t{m.group(1)}")
                del m
        if execute:
            with open(md_file, "w") as f:
                f.write(new_content)
        else:
            debug(" " * 4, "SKIPPED: flag '-r' is unset")


if __name__ == "__main__":
    argparser = argparse.ArgumentParser(
        description="Utility to transcribe md files using '<!-- cmdrun' to markdown",
        epilog=f"""\
rg '<!-- cmdrun fetch_discourse_md.py "(.*?)".*' --files-with-matches DIR | xargs {os.path.basename(__file__)} -r
""",
    )
    argparser.add_argument(
        "-r",
        "--run",
        help="Add this flag to disable dry run",
        action="store_true",
    )
    argparser.add_argument(
        "file",
        help="Markdown files to transcribe",
        nargs="+",
        type=Path,
    )

    args = argparser.parse_args()

    files = cast(list[Path], args.file)
    for f in files:
        if not f.exists():
            raise FileNotFoundError(f)
        if not f.is_file():
            raise Exception(f"{f} must be a file")
    try:
        transcribe(args.run, files_with_cmdrun=args.file)

    except KeyboardInterrupt:
        pass
