__doc__ = """Replace urls across the entire book"""

import json
import sys

from urllib.parse import urlparse

from libs.utils import Utils, debug as _debug


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
    book: dict[str, list]

    config = Utils.get_config_from_ctx("replace-urls", context)
    if not config:
        print(json.dumps(book))
        exit(0)
    elif not isinstance(config, dict):
        print(json.dumps(book))
        exit(0)

    debug(config)

    config_mappings: dict = config["mappings"]

    # Get the url mappings
    url_mappings: list[tuple[str, str]] = [
        (k, v)
        for k, v in config_mappings.items()
        if k not in _IGNORE_STRINGS and is_url(k)
    ]
    debug(url_mappings)

    book_s = json.dumps(book)
    for mapp_old, map_new in url_mappings:
        book_s = book_s.replace(mapp_old, map_new)

    print(book_s)
