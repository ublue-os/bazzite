from copy import copy
import re
import shlex
import subprocess


CMDRUN_PATTERN = r"<!--\s?cmdrun\s(.*)-->"


def _cmdrun_sub_handler(match: re.Match) -> str:
    cmd = match.group(1)
    proc = subprocess.run(shlex.split(cmd), capture_output=True, text=True)
    return proc.stdout.strip()


def on_page_markdown(markdown: str, **kargs):
    markdown_orig = markdown
    result = copy(markdown_orig)

    # First find all iterations of `<!-- cmdrun whatevercommand -->`
    result = re.sub(CMDRUN_PATTERN, _cmdrun_sub_handler, markdown_orig)

    return result
