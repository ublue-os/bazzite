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


########################### ONLY MODIFY THIS ###########################
URL_MAPPINGS = [
    # region GENERAL
    (  # src/index.md
        "https://universal-blue.discourse.group/docs?topic=561",
        "/",
    ),
    (  # src/General/reporting_bugs.md
        "https://universal-blue.discourse.group/docs?topic=3402",
        "/General/reporting_bugs",
    ),
    # region INSTALLATION GUIDE
    (  # src/General/Installation_Guide/Installing_Bazzite_for_HTPC_Setups.md
        "https://universal-blue.discourse.group/docs?topic=1145",
        "/General/Installation_Guide/Installing_Bazzite_for_HTPC_Setups/",
    ),
    (  # src/General/Installation_Guide/index.md
        "https://universal-blue.discourse.group/docs?topic=35",
        "/Installing_and_Managing_Software/",
    ),
    (  # src/General/Installation_Guide/dual_boot_setup_guide.md
        "https://universal-blue.discourse.group/docs?topic=2743",
        "/General/Installation_Guide/dual_boot_setup_guide/",
    ),
    (  # src/General/Installation_Guide/secure_boot.md
        "https://universal-blue.discourse.group/docs?topic=2742",
        "/General/Installation_Guide/secure_boot",
    ),
    (  # src/General/Installation_Guide/troubleshoot_guide.md
        "https://universal-blue.discourse.group/docs?topic=2495",
        "/General/Installation_Guide/troubleshoot_guide/",
    ),
    # endregion INSTALLATION GUIDE
    # endregion GENERAL
    # region SOFTWARE
    (  # src/Installing_and_Managing_Software/Updates_Rollbacks_&_Rebasing/index.md
        "https://universal-blue.discourse.group/docs?topic=36",
        "/Installing_and_Managing_Software/Updates_Rollbacks_&_Rebasing/",
    ),
    (  # src/Installing_and_Managing_Software/Updates_Rollbacks_&_Rebasing/updating_guide.md
        "https://universal-blue.discourse.group/docs?topic=2637",
        "/Installing_and_Managing_Software/Updates_Rollbacks_&_Rebasing/updating_guide/",
    ),
    (  # src/Installing_and_Managing_Software/Updates_Rollbacks_&_Rebasing/rolling_back_system_updates.md
        "https://universal-blue.discourse.group/docs?topic=2644",
        "/Installing_and_Managing_Software/Updates_Rollbacks_&_Rebasing/rolling_back_system_updates/",
    ),
    (  # src/Installing_and_Managing_Software/Updates_Rollbacks_&_Rebasing/rebase_guide.md
        "https://universal-blue.discourse.group/docs?topic=2646",
        "/Installing_and_Managing_Software/Updates_Rollbacks_&_Rebasing/rebase_guide/",
    ),
    (  # src/Installing_and_Managing_Software/Updates_Rollbacks_&_Rebasing/bazzite_rollback_helper.md
        "https://universal-blue.discourse.group/docs?topic=2647",
        "/Installing_and_Managing_Software/Updates_Rollbacks_&_Rebasing/bazzite_rollback_helper/",
    ),
    # endregion SOFTWARE
    (  # src/Gaming/index.md
        "https://universal-blue.discourse.group/docs?topic=31",
        "/Gaming/",
    ),
    # region HTPC
    (  # src/Handheld_and_HTPC_edition/Handheld_Wiki/index.md
        "https://universal-blue.discourse.group/docs?topic=1038",
        "/Handheld_and_HTPC_edition/Handheld_Wiki/",
    ),
    (  # src/Handheld_and_HTPC_edition/Handheld_Wiki/Steam_Deck.md
        "https://universal-blue.discourse.group/docs?topic=1849",
        "/Handheld_and_HTPC_edition/Handheld_Wiki/Steam_Deck/",
    ),
    (  # src/Handheld_and_HTPC_edition/Steam_Gaming_Mode.md
        "https://universal-blue.discourse.group/docs?topic=37",
        "/Handheld_and_HTPC_edition/Steam_Gaming_Mode/",
    ),
    # endregion HTPC
    # region ADVANCED
    (
        # src/Advanced/Auto-Mounting_Secondary_Drives.md
        "https://universal-blue.discourse.group/docs?topic=970",
        "/Advanced/Auto-Mounting_Secondary_Drives/",
    ),
    # endregion ADVANCED
]

########################################################################


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
