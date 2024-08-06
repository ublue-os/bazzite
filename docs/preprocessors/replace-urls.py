__doc__ = """Replace urls across the entire book"""

from dataclasses import asdict, dataclass
from functools import singledispatch
from glob import glob
import json
from pathlib import Path
import sys

from typing import Self, cast, overload
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


@dataclass
class Chapter(dict):
    name: str
    content: str
    number: int
    path: str
    source_path: str
    parent_names: list[str]

    def __init__(self, name, content, number, path, source_path, parent_names):
        self.name = name
        self.content = content
        self.number = number
        self.path = path
        self.source_path = source_path
        self.parent_names = parent_names
        self._ref = dict()

    @classmethod
    def from_dict(cls, d: dict) -> Self:
        inst = cls(
            name=d["name"],
            content=d["content"],
            number=d["number"],
            path=d["path"],
            source_path=d["source_path"],
            parent_names=d["parent_names"],
        )
        inst._ref = d
        return inst


class Chap(object):
    def __init__(self, d) -> None:
        self.__dict__ = d
        self.name: str = self.__dict__["name"]
        self.content: str = self.__dict__["content"]
        self.number: int = self.__dict__["number"]
        self.path: str = self.__dict__["path"]
        self.source_path: str = self.__dict__["source_path"]
        self.parent_names: list[str] = self.__dict__["parent_names"]


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

    ignore_paths = config.get("ignore") or []
    debug(config)

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

    book_aux: dict[str, list[dict]] = book.copy()

    for idx, section in enumerate(book["sections"].copy()):
        section: dict
        if not section.get("Chapter"):
            continue

        chapter = Chap(section["Chapter"])

        if chapter.path in ignore_paths:
            continue

        for old_url, new_url in url_mappings:
            chapter.content.replace(old_url, new_url)
        book_aux["sections"][idx] = section

    book.update(book_aux)
    print(json.dumps(book))
