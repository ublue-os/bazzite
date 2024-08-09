__doc__ = """Example of a mdbook preprocessor"""

import datetime
import json
import os
import re
import sys
from typing import Any


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


def modify_content(content: str) -> str | None:
    ############## MODIFY 'content' HERE ##############
    """Alter the contents of each chapter

    Args:
        content (str):  The contents of a chapter received. Is in markdown format.

    Returns:
        str | None: The chapter contents modified.
        If `None`, the original content will be used instead
    """

    author_template = "<div>" + r"""Publisher: \g<username>""" + "</div>"
    author_pattern = r"\A(?P<username>\w+)\s\|\s(?P<date>(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2}))\s(?P<time>(?P<hour>\d{2}):(?P<min>\d{2}):(?P<sec>\d{2})\s(?P<zone>\w+))\s\|\s#\d+"
    if re.match(author_pattern, content, re.MULTILINE):
        content = re.sub(author_pattern, author_template, content)

    return content
    ###################################################


#
#
#
#
#
#
#
#
#
#
#
#

if __name__ == "__main__":
    if len(sys.argv) > 1:
        if sys.argv[1] == "supports":
            sys.exit(0)
    context, book = json.load(sys.stdin)
    book: dict[str, list]
    context: dict
    debug(f"context: {context}")

    sections = book["sections"]

    for i, section in enumerate(sections):
        section: dict
        if not section.get("Chapter"):
            continue
        for chapter in section.values():
            chapter: dict
            debug(chapter)
            content: str = chapter["content"]

            if type(content) is str and (res := modify_content(content)):
                content = res

            chapter.update({"content": content})
            debug(book)
    print(json.dumps(book))
