#!/usr/bin/env python

__doc__ = """ Utility to extract pages from Discourse posts in a Markdown format

@author: Zeglius """

import html
import json
import os
import re
from argparse import ArgumentParser
from datetime import UTC, datetime
from string import Template
from sys import stderr, stdout
from typing import NamedTuple

import requests

_is_debug: bool = False

_BASE_URL = "https://universal-blue.discourse.group"


class UrlBatch(NamedTuple):
    raw_url: str
    json_url: str
    source_url: str


type HTMLPage = str
type Markdown = str


def todo(msg: str = "TODO"):
    """Equivalent to rust `todo!()`"""
    msg = str.removeprefix(msg, "TODO")
    raise NotImplementedError(msg)


def debug(*msg) -> None:
    """Print to stderr if `_is_debug` is `True`"""
    global _is_debug
    if _is_debug:
        return print(
            f"[DEBUG {__file__}, PID={os.getpid()}]:",
            *(o.__str__() for o in msg),
            file=stderr,
        )


session = requests.Session()


class DiscourseProcessor:

    class Patterns:
        post_sep_markdown = re.compile(r"-------------------------")
        imgs_urls = re.compile(
            r"<img\ssrc=\"(?P<image_cdn_url>https://(?:[a-zA-Z0-9./_-]+)).*data-base62-sha1=\"(?P<sha1>[a-zA-Z0-9]+)\".*\">"
        )
        hashed_images_urls = re.compile(r"upload://([a-zA-Z0-9]+)", flags=re.I | re.M)
        author_header_pttrn = re.compile(
            r"^(?P<username>\w+)\s\|\s(?P<date>(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2}))\s(?P<time>(?P<hour>\d{2}):(?P<min>\d{2}):(?P<sec>\d{2})\s(?P<zone>\w+))\s\|\s#\d+"
        )

    @classmethod
    def transform_to_url_batch(cls, url: str) -> UrlBatch:
        """Input a discourse url topic and return a batch of urls such as `/raw/{id}` and `/t/{id}.json`

        Args:
            url (str)
        """
        res = None

        # Get topic id
        site_prefix = _BASE_URL.rstrip("/")
        id = re.search(rf"{re.escape(site_prefix)}/docs\?topic=(\d+)", url)
        if id is None:
            raise Exception("id was not found")
        id = int(id.group(1))

        res = UrlBatch(
            json_url=rf"{site_prefix}/t/{id}.json",
            raw_url=rf"{site_prefix}/raw/{id}",
            source_url=url,
        )

        return res

    @classmethod
    def add_metadata_to_markdown(cls, md: Markdown, url_discourse: str) -> Markdown:
        """Add commented metadata to a markdown page"""
        meta_tmpl = Template(
            "\n".join(
                [
                    "<!-- ANCHOR: METADATA -->",
                    "<!--$metadata-->",
                    "<!-- ANCHOR_END: METADATA -->",
                ]
            ).strip()
        )
        metadata_str = html.escape(
            json.dumps(
                dict(
                    url_discourse=url_discourse,
                    fetched_at=str(datetime.now(UTC)),
                ),
            ),
            quote=False,
        )
        meta = meta_tmpl.substitute(metadata=metadata_str)
        return re.sub(cls.Patterns.author_header_pttrn, meta, md, count=1)


def simple_replace_match(match: re.Match) -> str:
    hash = match.group(1)
    if hash:
        return f"{_BASE_URL}/uploads/short-url/{hash}"
    return ""


def fetch(url: str) -> str | None:

    batch = DiscourseProcessor.transform_to_url_batch(url)

    md_url = batch.raw_url

    result = session.get(md_url).text

    # Replace images urls
    result = re.sub(
        DiscourseProcessor.Patterns.hashed_images_urls,
        simple_replace_match,
        result,
    )

    # Remove comments
    result = DiscourseProcessor.Patterns.post_sep_markdown.split(result, 1)[0].rstrip()

    # Add metadata
    result = DiscourseProcessor.add_metadata_to_markdown(result, batch.source_url)

    return result


def main():
    argparser = ArgumentParser()
    argparser.add_argument(
        "url",
        type=str,
        help="discourse urls to be processed",
    )
    argparser.add_argument(
        "-d",
        "--debug",
        help="Show additional info in stderr",
        action="store_true",
        dest="debug",
        default=False,
    )
    args = argparser.parse_args()

    global _is_debug
    _is_debug = os.getenv("DEBUG") == "1" or args.debug

    result = fetch(args.url)

    print(result, file=stdout)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
