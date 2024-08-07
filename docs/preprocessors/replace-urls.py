__doc__ = """Replace urls across the entire book"""

from copy import copy
import glob
import json
from pathlib import Path
import sys

from typing import cast
from urllib.parse import urlparse

from libs.utils import Utils, debug as _debug
from libs.types import MdBook


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


if __name__ == "__main__":
    if len(sys.argv) > 1:
        if sys.argv[1] == "supports":
            sys.exit(0)
    context, book = json.load(sys.stdin)

    book = MdBook(book)

    config = Utils.get_config_from_ctx("replace-urls", context)
    if not config:
        print(json.dumps(book._data))
        exit(0)
    elif not isinstance(config, dict):
        print(json.dumps(book._data))
        exit(0)

    ignore_paths_list_globs = cast(list[str], list(config.get("ignore") or []))
    ignore_paths: list[str] = []
    root_dir = Path(context["root"], context["config"]["book"]["src"])
    for p in ignore_paths_list_globs:
        ignore_paths += glob.glob(p, root_dir=root_dir)

    debug("My ignored paths:", ignore_paths)

    config_mappings: dict = config["mappings"]

    # Get the url mappings
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
            old = copy(section.chapter.content)
            section.chapter.content = section.chapter.content.replace(old_url, new_url)

    print(json.dumps(book._data))
