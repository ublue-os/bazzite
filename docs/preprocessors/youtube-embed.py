import datetime
import difflib
import json
import os
import re
import sys
from typing import Any, Type


YOUTUBE_URL_PATTERN = r"(?<!<)https:\/\/(?:www\.youtube\.com\/watch\?v=|youtu\.be\/(?!watch))(?P<id>[a-zA-Z0-9_-]{11})"
YOUTUBE_EMBED_TEMPLATE = """<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/\\g<id>" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>"""

_DEBUG = os.getenv("DEBUG", "")


def debug(*obj) -> Any:
    return obj


if _DEBUG in ["1", "yes"]:
    _DEBUG_OUTPUT = "./debug.txt"
    if os.path.exists(_DEBUG_OUTPUT):
        os.truncate(_DEBUG_OUTPUT, 0)

    def debug(*obj) -> Any:
        with open(_DEBUG_OUTPUT, "+a") as stdout:
            print(f"DEBUG[{datetime.date.today()}]:", *obj, file=stdout)
        return obj


if __name__ == "__main__":
    if len(sys.argv) > 1:
        if sys.argv[1] == "supports":
            sys.exit(0)
    context, book = json.load(sys.stdin)
    book: dict[str, list]
    context: dict

    sections = book["sections"]

    for i, section in enumerate(sections):
        section: dict
        if not section.get("Chapter"):
            continue
        for chapter in section.values():
            chapter: dict
            debug(chapter)
            content: str = chapter["content"]
            chapter.update(
                {
                    "content": re.sub(
                        YOUTUBE_URL_PATTERN, YOUTUBE_EMBED_TEMPLATE, content
                    )
                }
            )
            debug(book)
    print(json.dumps(book))
