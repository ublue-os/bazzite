import re
from mkdocs import plugins


YOUTUBE_URL_PATTERN = r"(?<!<|\(|\")\bhttps:\/\/(?:www\.youtube\.com\/watch\?v=|youtu\.be/)(?P<id>[a-zA-Z0-9_-]{11})\b"


def _generate_embed_from_id(
    yt_id: str,
    /,
    *,
    width: int = 560,
    height: int = 315,
) -> str:
    """Generate a youtube embed from a video id"""
    return f"""\
<iframe width="{width}" height="{height}" src="https://www.youtube.com/embed/{yt_id}" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>"""


def on_page_content(html: str, **kargs):
    def resub_handler(match: re.Match) -> str:
        id = match.group("id")
        if id:
            return _generate_embed_from_id(id)
        return match.string

    return re.sub(YOUTUBE_URL_PATTERN, resub_handler, html)
