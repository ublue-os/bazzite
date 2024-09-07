#!/usr/bin/env python


import re
from argparse import ArgumentParser
from pathlib import Path, PosixPath
from typing import cast

import requests
import urllib3
import urllib3.util

IMG_RE = re.compile(r"\B\!\[(?P<name>[^\]]*)\]\((?P<url>.*?)\)\B", flags=re.M | re.A)

session: requests.Session
output_dir: Path
input_files: list[Path]
is_replace: bool


def _download_img(url: urllib3.util.Url, file_path: Path):
    """Download an image.

    Args:
        url (urllib3.util.Url): Image source
        file_path (Path): File to store in the image
    """
    global session
    if file_path.exists():
        print(f"File {file_path} already exists, skipping...")
        return file_path

    r = session.get(url.url, stream=True)
    with open(file_path, "wb") as fd:
        for chunk in r.iter_content(chunk_size=128):
            fd.write(chunk)
    return file_path


def handle_img_match(md_file: Path):
    def _handler(match: re.Match[str]) -> str:
        global session, output_dir

        img_url = urllib3.util.parse_url(match.group("url"))
        if not img_url.path:
            return match.string
        img_filename = PosixPath(img_url.path).name
        img_down = _download_img(img_url, output_dir / img_filename)
        img_path = Path.relative_to(img_down, md_file.parent, walk_up=True)
        return match.expand(rf"![\g<name>]({img_path})")

    return _handler


if __name__ == "__main__":
    argparser = ArgumentParser(description="Download images from discourse short-urls")
    argparser.add_argument(
        "-o", "--output", help="Directory to dump images in", type=Path
    )
    argparser.add_argument("input", help="Markdown file to parse", nargs="+", type=Path)
    argparser.add_argument(
        "-r",
        "--replace",
        help="Replace urls in the markdown file",
        action="store_true",
    )

    args = argparser.parse_args()

    output_dir = Path(args.output)
    assert output_dir.exists() and output_dir.is_dir()
    input_files = cast(list[Path], args.input)
    is_replace = args.replace

    session = requests.Session()

    # Start parsing files
    for md_file in input_files:
        assert md_file.exists() and md_file.is_file()
        content = md_file.read_text()

        content = IMG_RE.sub(handle_img_match(md_file), string=content)
        if is_replace:
            md_file.write_text(content)
