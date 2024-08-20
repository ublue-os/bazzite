import os
import sys

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from copy import copy
import re
from fetch_discourse_md import fetch as fetch_md_discourse


CMDRUN_PATTERN = r"<!--\s?cmdrun\s+fetch_discourse_md\.py\s+\"(.*)\"\s*-->"


def _cmdrun_sub_handler(match: re.Match) -> str:
    print(match.group(1))
    url = match.group(1)
    result = fetch_md_discourse(url)
    return result or ""


def on_page_markdown(markdown: str, **kargs):
    markdown_orig = markdown
    result = copy(markdown_orig)

    try:
        # First find all iterations of `<!-- cmdrun whatevercommand -->`
        result = re.sub(CMDRUN_PATTERN, _cmdrun_sub_handler, markdown_orig)
    except Exception as err:
        print("ERROR", err)

    return result
