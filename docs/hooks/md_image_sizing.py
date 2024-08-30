import logging
import os
import re
from mkdocs.config.defaults import MkDocsConfig
from mkdocs.structure.pages import Page
from mkdocs.structure.files import Files


IMG_TAG_RE = r"\!\[(.*)\]\(.*\)"
"""Find a `![text](url)`, with `group(1)` being the `text` segment"""

# IMG_SIZE_SUFFIX_RE = r"(?<=\|)\s*(?P<width>\d+)x(?P<height>\d+)\b"
IMG_SIZE_SUFFIX_RE = r"(?<=\|)\s*(?P<width>\d+)x(?P<height>\d+)(?:,.*?(?P<multi>\d+)%)?"
"""Used to get width, height from `text|WIDTHxHEIGHT`"""


def _add_attr_handler(match: re.Match[str]) -> str:
    in_brackets = match.group(1)
    if not in_brackets:
        return match.string

    # Extract size
    aux = re.search(IMG_SIZE_SUFFIX_RE, in_brackets)
    if not aux:
        return match.string
    width = aux.group("width")
    height = aux.group("height")
    if multi := aux.group("multi"):
        multi = int(multi) / 100
        width = str(int(width) * multi)
        height = str(int(height) * multi)
    res = "".join(
        [match.group(), """{ style="width:%spx; height:%spx;" }""" % (width, height)]
    )
    return res


is_enabled: bool


def on_config(config: MkDocsConfig):
    global is_enabled
    is_enabled = "attr_list" in config.markdown_extensions


def on_page_markdown(
    markdown: str, page: Page, config: MkDocsConfig, files: Files, **kargs
):
    if is_enabled:
        return re.sub(IMG_TAG_RE, _add_attr_handler, markdown)
    return markdown
