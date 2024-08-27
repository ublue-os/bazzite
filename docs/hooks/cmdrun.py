import hashlib
import os
from pathlib import Path
import sys
from mkdocs.config.defaults import MkDocsConfig
from mkdocs import plugins
from mkdocs.structure.pages import Page
from mkdocs.structure.files import Files

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from copy import copy
import re
from fetch_discourse_md import fetch as fetch_md_discourse


URL_MAPPINGS = [
    (  # src/index.md
        "https://universal-blue.discourse.group/docs?topic=561",
        "/",
    ),
    (  # src/Handheld_and_HTPC_edition/Handheld_Wiki/index.md
        "https://universal-blue.discourse.group/docs?topic=1038",
        "/Handheld_and_HTPC_edition/Handheld_Wiki/",
    ),
    (  # src/Handheld_and_HTPC_edition/Handheld_Wiki/Steam_Deck.md
        "https://universal-blue.discourse.group/docs?topic=1849",
        "/Handheld_and_HTPC_edition/Handheld_Wiki/Steam_Deck/",
    ),
    (  # src/Handheld_and_HTPC_edition/Steam_Gaming_Mode/index.md
        "https://universal-blue.discourse.group/docs?topic=37",
        "/Handheld_and_HTPC_edition/Steam_Gaming_Mode/",
    ),
]


CMDRUN_PATTERN = r"<!--\s?cmdrun\s+fetch_discourse_md\.py\s+\"(.*)\"\s*-->"
PLUGIN_NAME = os.path.basename(__file__).rstrip(".py")

plugin_cache_dir: str


def _cache_filename_generator(text: str) -> str:
    """Generate a sha265 encoded cache file path of a piece of text inside the plugin cache dir"""
    cache_file = os.path.join(
        plugin_cache_dir, hashlib.sha256(text.encode()).hexdigest()
    )
    return cache_file


def _fetch_callback(url: str):
    cache_file = _cache_filename_generator(url)
    if os.path.exists(cache_file):
        return Path(cache_file).read_text().strip()

    elif content := fetch_md_discourse(url):
        with open(cache_file, "w+t") as c_file:
            c_file.write(content)
        return content
    else:
        return ""


def _cmdrun_sub_handler(match: re.Match) -> str:
    print(match.group(1))
    url = match.group(1)
    result = _fetch_callback(url)
    return result or ""


def on_config(config: MkDocsConfig):
    """Initialize cache dir"""
    global plugin_cache_dir
    plugin_cache_dir = os.path.join(
        os.path.dirname(config.config_file_path), ".cache", PLUGIN_NAME
    )
    try:
        os.makedirs(plugin_cache_dir, exist_ok=True)
    except FileExistsError:
        pass


@plugins.event_priority(100)
def _on_page_markdown_fetch_discourse(markdown: str, **kargs):
    markdown_orig = markdown
    result = copy(markdown_orig)

    try:
        result = re.sub(CMDRUN_PATTERN, _cmdrun_sub_handler, markdown_orig)
    except Exception as err:
        print("ERROR", err)

    return result


@plugins.event_priority(99)
def _on_page_markdown_replace_urls(
    markdown: str,
    page: Page,
    config: MkDocsConfig,
    files: Files,
    **kargs,
):
    """Replace discourse urls"""
    res = markdown
    for src, dst in URL_MAPPINGS:
        if config.site_url:
            dst = f"{config.site_url.rstrip("/")}/{dst.lstrip("/")}"
        res = res.replace(src, dst)
    return res


on_page_markdown = plugins.CombinedEvent(
    _on_page_markdown_fetch_discourse,
    _on_page_markdown_replace_urls,
)
