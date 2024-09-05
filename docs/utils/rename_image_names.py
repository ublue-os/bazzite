#!/usr/bin/env python


import argparse
import hashlib
import re
import shutil
import subprocess
from pathlib import Path

IMG_REF_RE = r"\B\!\[(?P<label>[^\]]*)\]\((?P<url>\.[^\)]*)\)\B"


class MissingSystemDepsError(Exception):
    pass


_filenamechars_mapping = str.maketrans(
    {
        "&": "and",
        " ": "_",
        "(": "",
        ")": "",
        ".": "_",
        "'": "",
        "*": "",
    }
)


def find_matching_name(md_file_path: str | Path, /, pattern: str = IMG_REF_RE):
    try:
        pout = Path(md_file_path).read_text()
    except UnicodeDecodeError:
        return
    pout = pout.strip()
    m = re.search(pattern, pout)
    if not m:
        return None
    label = m.group("label")
    url: str = m.group("url")

    aux_label = re.match(r"^[^\|]*", label, flags=re.M)
    label = aux_label.group() if aux_label else ""
    label = label.translate(_filenamechars_mapping)
    # If the label is simple numbers or too generic, attach a hash
    if re.match(r"^\d{1,3}", label, flags=re.M):
        with open(md_file_path, "rb") as f:
            label = "_".join([label, hashlib.sha1(f.read()).hexdigest()[0:7]])
    old_name = Path(url).name
    new_name = Path(url).with_stem(label).name

    return old_name, new_name


if __name__ == "__main__":
    argparser = argparse.ArgumentParser(
        description="Replace images names in markdown files",
        epilog="""./utils/rename_image_names.py --images-dir src/img/ $(fd .md src/)""",
    )
    argparser.add_argument(
        "inputfiles", help="Files you want to parse", type=Path, nargs="+"
    )
    argparser.add_argument(
        "--images-dir",
        help="directory where images files are located",
        type=Path,
        required=True,
    )
    args = argparser.parse_args()

    input_files: list[Path] = args.inputfiles
    assert all([x.exists() for x in input_files])
    images_dir: Path = args.images_dir

    # For directories, get their markdown
    for entry in input_files:
        if entry.is_dir():
            p = list(entry.rglob(".md"))
            del entry
            input_files.extend(p)

    # Get the mappings
    mappings = {x[0]: x[1] for x in map(find_matching_name, input_files) if x}

    # Replace img file names
    for old, new in mappings.items():
        old_file = list(images_dir.rglob(f"**/{old}*"))
        if old_file.__len__() <= 0:
            continue
        old_file = old_file[0]
        old_file.rename(old_file.with_name(new))

    # Rename links in md files
    for old, new in mappings.items():
        for md_file in input_files:
            try:
                content = md_file.read_text()
            except UnicodeDecodeError:
                continue
            content = re.sub(rf"\b{re.escape(old)}\b", new, content)
            md_file.write_text(content)
            del content
