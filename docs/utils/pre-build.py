#!/usr/bin/env python

__doc__ = """Preprocess markdown files in order to be processed by mdbook-i18n-helpers
"""

import argparse
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys
from typing import Optional


def execute_command(command: Optional[str]) -> str:
    if not command:
        return ""
    try:
        result = subprocess.run(
            shlex.split(command),
            check=True,
            capture_output=True,
            text=True,
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as err:
        return f"Error: {err.stderr.strip()}"


def debug(*msg) -> None:
    if os.getenv("DEBUG") == "1":
        return print("[DEBUG]:", *msg, file=sys.stderr)


def exe_wrapper(match: re.Match[str]):
    return execute_command(match.group(1) or None)


def render(content: str):
    templ = r"<!-- cmdrun (.*)\s?-->\n?"
    return re.sub(templ, exe_wrapper, content)


def main():
    argparser = argparse.ArgumentParser()
    argparser.add_argument(
        "-s",
        "--src",
        help="Directory with all markdown files",
        type=str,
        required=True,
    )
    argparser.add_argument(
        "-o",
        "--output",
        help="Where to store files",
        required=True,
    )

    args = argparser.parse_args()
    # Move files to temporary directory
    src_md_directory = Path(args.src)
    _dst_md_directory = Path(args.output)
    if _dst_md_directory.exists():
        shutil.rmtree(_dst_md_directory)
    dst_md_directory = shutil.copytree(src_md_directory, _dst_md_directory)

    files_to_parse = [Path(f) for f in dst_md_directory.glob("**/*.md")]

    for file in files_to_parse:
        content_to_write: str = render(file.read_text(encoding="utf-8"))
        with open(file, "w") as out:
            out.write(content_to_write)
        debug(f"File '{file.name}' was parsed")

    print(dst_md_directory)


if __name__ == "__main__":
    main()
