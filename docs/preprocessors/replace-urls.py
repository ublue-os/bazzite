__doc__ = """Replace urls across the entire book"""

import glob
import json
from pathlib import Path
import sys

from typing import List, cast
from urllib.parse import urljoin, urlparse

from libs.utils import debug as _debug
from libs.types import MdBook

PREPROCESSOR_NAME = "replace-urls"


def debug(*obj):
    return _debug("REPLACE-URLS:", *obj)


_IGNORE_STRINGS = [
    "before",
    "after",
    "command",
    "renderers",
]


def is_url(url) -> bool:
    res: bool = False
    try:
        tmp = urlparse(url)
        res = tmp.netloc != "" and tmp.scheme != ""
    except Exception as _:
        res = False
    return res


def main():
    if len(sys.argv) > 1:
        if sys.argv[1] == "supports":
            sys.exit(0)
    context, book = json.load(sys.stdin)

    book = MdBook(book)

    config = context["config"]["preprocessor"][PREPROCESSOR_NAME]
    if not config:
        print(json.dumps(book._data))
        exit(0)
    elif not isinstance(config, dict):
        print(json.dumps(book._data))
        exit(0)

    book_src = cast(str, context["config"]["book"]["src"])

    # Prefix to append to replaced urls if output.html.site-url is set and the replacement starts with `/`
    try:
        site_url_prefix = cast(str, context["config"]["output"]["html"]["site-url"])
    except Exception as _:
        site_url_prefix = ""

    ignore_paths_list_globs = cast(list[str], list(config.get("ignore") or []))
    ignore_paths: List[str] = list()
    root_dir = Path(context["root"], book_src)
    for p in ignore_paths_list_globs:
        ignore_paths += glob.glob(p, root_dir=root_dir)

    debug("My ignored paths:", ignore_paths)

    config_mappings: dict = config["mappings"]

    # Get the url mappings
    # If replacement starts with `/`, prepend
    url_mappings: list[tuple[str, str]] = [
        (k, v)
        for k, v in config_mappings.items()
        if k not in _IGNORE_STRINGS and is_url(k)
    ]

    # Replace the urls
    # book_s = json.dumps(book)
    # for mapp_old, map_new in url_mappings:
    #     book_s = book_s.replace(mapp_old, map_new)

    for section in book.sections:
        if not section.chapter:
            debug("Section skipped, was parttitle:", section.part_title)
            continue

        debug("section.chapter.path =", section.chapter.path)
        if section.chapter.path in ignore_paths:
            debug("Section skipped, was in ignore_paths:", section.chapter.path)
            continue

        for old_url, new_url in url_mappings:
            if new_url.startswith("/"):
                new_url_aux = urljoin(site_url_prefix, new_url.lstrip("/"))
            else:
                new_url_aux = new_url
            section.chapter.content = section.chapter.content.replace(
                old_url, new_url_aux
            )

    print(json.dumps(book._data))


if __name__ == "__main__":
    main()
