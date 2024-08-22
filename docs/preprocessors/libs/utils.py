import datetime
import os
from pathlib import Path
from typing import Any, Optional


# Example mdBook context
example_ctx = {
    "root": "/var/home/zeglius/Documentos/Github/bazzite_mdbook/docs",
    "config": {
        "book": {
            "authors": ["nicknamenamenick", "Zeglius"],
            "language": "en",
            "multilingual": False,
            "src": "src",
            "title": "Bazzite Documentation",
        },
        "build": {
            "build-dir": "book",
            "create-missing": False,
            "extra-watch-dirs": [],
            "use-default-preprocessors": False,
        },
        "output": {
            "html": {
                "edit-url-template": "https://github.com/ublue-os/bazzite/edit/main/docs/{path}",
                "git-repository-url": "https://github.com/ublue-os/bazzite",
            }
        },
        "preprocessor": {
            "links": {},
            "youtube-embed": {"command": "python ./preprocessors/youtube-embed.py"},
        },
    },
    "renderer": "html",
    "mdbook_version": "0.4.40",
}


class Utils:

    @staticmethod
    def get_config_from_ctx(preprocessor_name: str, ctx: dict) -> Optional[dict]:
        """Get the config from mdBook context

        Returns:

        """
        ctx.get("")
        return ctx["config"]["preprocessor"][preprocessor_name]


####################### DEBUG UTILS #######################

_DEBUG = os.getenv("DEBUG", "")
_DEBUG_OUTPUT = Path("./debug.txt")


def debug(*obj: object):
    """Dump info into a debug.txt if env var DEBUG=1"""
    if _DEBUG in ["1", "yes"]:
        with open(_DEBUG_OUTPUT, "+a") as stdout:
            print(f"DEBUG[{datetime.date.today()}]:", *obj, file=stdout)


###########################################################


__all__ = ["Utils", "debug"]
