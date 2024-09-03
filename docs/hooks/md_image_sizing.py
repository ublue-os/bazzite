import re
import string
from mkdocs.config.defaults import MkDocsConfig
from mkdocs.structure.pages import Page
from mkdocs.structure.files import Files
from mkdocs.plugins import event_priority


IMG_SIZED_RE = (
    r"\!\[.*?\s*(?P<width>\d+)x(?P<height>\d+)(?:,\s*(?P<multi>\d+)%)?\]\(.*\)"
)
"""Used to get width, height from `text|WIDTHxHEIGHT`"""


def _add_attr_handler(match: re.Match[str]) -> str:
    width = match.group("width")
    height = match.group("height")
    if multi := match.group("multi"):
        multi = int(multi) / 100
        width = str(int(width) * multi)
        height = str(int(height) * multi)
    res = match.group(0) + string.Template(
        '{ style="max-width:${width}px; max-height:${height}px; width: 100%;" }'
    ).substitute(width=width, height=height)
    return res


is_enabled: bool


def on_config(config: MkDocsConfig):
    global is_enabled
    is_enabled = "attr_list" in config.markdown_extensions


@event_priority(70)
def on_page_markdown(
    markdown: str, page: Page, config: MkDocsConfig, files: Files, **kargs
):
    if is_enabled:
        return re.sub(IMG_SIZED_RE, _add_attr_handler, markdown)
