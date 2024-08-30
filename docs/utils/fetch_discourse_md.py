#!/usr/bin/env python

__doc__ = """ Utility to extract pages from Discourse posts in a Markdown format

@author: Zeglius

Quick Glossary:
    - HTMLPage: an HTML page contents
    - Markdown: a Markdown page contents

How does this script work:
    1.  Pass Discourse docs topic URL as argument
        ```sh
        ./fetch_discourse_md.py "https://universal-blue.discourse.group/docs?topic=1146"
        ```

    2.  Create an UrlBatch for each URL passed.
        An UrlBatch is a named tuple which contents are:
            - An URL pointing to the raw markdown of the topic (ex.: https://universal-blue.discourse.group/raw/1146)
            - An URL pointing to the json format of the topic (ex.: https://universal-blue.discourse.group/t/1146.json)

    We have a problem. We could simply use the raw markdown, but in that format, images URLs point to a route that Discourse
    use internally to fetch the images (ex:. upload://AliS5ytuj3Rro4xsxfHMnPiJMsR.jpeg).

    The solution lies in the json format of the topic. Specifically its field '.post_stream.posts[].cooked'.
    That field contains the already rendered html page, including the URLs pointing to the images in the CDN.

    Problem is, how do we match the images images in the markdown (ex.: upload://AliS5ytuj3Rro4xsxfHMnPiJMsR.jpeg) with the ones
    from the json (ex.: https://canada1.discourse-cdn.com/free1/uploads/univeral_blue/original/2X/f/feb6c68dc90b80d9432b6ce74a38f639b05202d5.jpeg)?
    
    This is an extract of the img element:

    ```html
    <img src="https://canada1.discourse-cdn.com/free1/uploads/univeral_blue/original/2X/f/feb6c68dc90b80d9432b6ce74a38f639b05202d5.jpeg" 
    alt="Desktop" 
    data-base62-sha1="AliS5ytuj3Rro4xsxfHMnPiJMsR" 
    width="690" height="448" data-dominant-color="4D5A5D">
    ```

    Bingo! `data-base62-sha1` contents match with that of the image URL in the markdown (ex.: upload://AliS5ytuj3Rro4xsxfHMnPiJMsR.jpeg).

    3.  Obtain the HTML page contents using the json url stored in the UrlBatch
        ```python
        @classmethod    
        def get_page_from_json(cls, batch: UrlBatch) -> HTMLPage:
            json_content = requests.get(batch.json_url).json()
            return json_content["post_stream"]["posts"][0]["cooked"]
        ```

    4.  From the HTML page, find the `<img>` tags with the next regex expression:
        ```regex
        <img src=\"(?P<image_cdn_url>https://(?:[a-zA-Z0-9./_-]+)).*data-base62-sha1=\"(?P<sha1>[a-zA-Z0-9]+)\".*\">
        ```
        Using this regex expression we obtain:
            - URL used by the CDN to store the image (group 'image_cdn_url')
            - SHA1 used by the markdown (ex.: upload://<SHA1>.jpeg) (group 'sha1')

    5.  Create a `img_url_assocs: list[tuple[str,str]]`, `dict` following this schema: `{"<SHA1>": "<image_cdn_url>"}`
        ```python
        @classmethod
        def get_images_url_assocs_from_page(cls, page: HTMLPage) -> list[tuple[str, str]]:
            result: list[dict[str, str]] = []
            for match in re.finditer(DiscourseProcessor.Patterns.imgs_urls, page):
                (sha1, image_cdn_url) = match.group("sha1", "image_cdn_url")
                result.append({sha1: image_cdn_url})
            return result
        ```

    Once we have associated each SHA1 with an image_cdn_url, its time to fetch the Markdown
    
    6.  Obtain markdown
        ```python
        @classmethod
        def get_markdown_from_raw(cls, batch: UrlBatch) -> Markdown:
            return requests.get(batch.raw_url).text
        ```

    7.  For each key in the `img_url_assocs` list, search with regex the _hashed urls_ (ex.: upload://AliS5ytuj3Rro4xsxfHMnPiJMsR.jpeg)
        and replace them with the image_cdn_url
        ```python
        for assoc in img_url_assocs:
            # TODO: Add example here
        ```
"""


from argparse import ArgumentParser
from datetime import datetime, UTC
import fcntl
import html
import json
import os
import re
from string import Template
from sys import stdout, stderr
from time import sleep
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
type ImageUrlAssocs = list[tuple[str, str]]


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


def acquire_lock(lock_file_path="/tmp/mylock.lock"):
    lock_file = open(lock_file_path, "w")
    fcntl.flock(lock_file, fcntl.LOCK_EX)
    return lock_file


class DiscourseProcessor:

    class Patterns:
        post_sep_markdown = re.compile(r"-------------------------")
        imgs_urls = re.compile(
            r"<img\ssrc=\"(?P<image_cdn_url>https://(?:[a-zA-Z0-9./_-]+)).*data-base62-sha1=\"(?P<sha1>[a-zA-Z0-9]+)\".*\">"
        )
        hashed_images_urls = re.compile(r"upload://([a-zA-Z0-9]+)", flags=re.I | re.M)

    @classmethod
    def transform_to_url_batch(cls, url: str) -> UrlBatch:
        """Input a discourse url topic and return a batch of urls such as `/raw/{id}` and `/t/{id}.json`

        Args:
            url (str)
        """
        res = None

        # Get topic id
        id = re.search(rf"{re.escape(_BASE_URL)}/docs\?topic=(\d+)", url)
        if id is None:
            raise Exception("id was not found")
        id = int(id.group(1))

        res = UrlBatch(
            json_url=f"https://universal-blue.discourse.group/t/{id}.json",
            raw_url=f"https://universal-blue.discourse.group/raw/{id}",
            source_url=url,
        )

        return res

    @classmethod
    def fetch(cls, url: str) -> requests.Response:
        tries = 2
        retry_pattern = r"Slow down, too many requests from this IP address. Please retry again in (\d+) seconds?\. Error code: ip_10_secs_limit\.$"

        while tries > 0:
            res = requests.get(url)
            if re.match(retry_pattern, res.text):
                debug("Timeout was hit: ", res.text)
                tries = tries - 1
                sleep(12)  # Usually is 10 seconds, +2 to be safe
                continue
            else:
                break

        return res

    @staticmethod
    def get_markdown_from_url(url: str):
        return requests.get(url).text

    @staticmethod
    def add_metadata_to_markdown(md: Markdown, url_discourse: str) -> Markdown:
        """Add commented metadata to a markdown page"""
        meta_tmpl = Template(
            "\n".join(
                [
                    "<!-- ANCHOR: METADATA -->",
                    "<!--$metadata-->",
                    "<!-- ANCHOR_END: METADATA -->",
                ]
            )
            .lstrip()
            .rstrip()
        )
        metadata = html.escape(
            json.dumps(
                dict(
                    url_discourse=url_discourse,
                    fetched_at=datetime.now(UTC).__str__(),
                ),
            ),
            quote=False,
        )
        md_split = md.splitlines()
        author_header_pttrn = r"^(?P<username>\w+)\s\|\s(?P<date>(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2}))\s(?P<time>(?P<hour>\d{2}):(?P<min>\d{2}):(?P<sec>\d{2})\s(?P<zone>\w+))\s\|\s#\d+"
        if re.match(author_header_pttrn, md_split[0]):
            md_split[0] = "\n".join(
                [md_split[0], "", meta_tmpl.substitute(metadata=metadata)]
            )
        return "\n".join(md_split)


def simple_replace_match(match: re.Match) -> str:
    hash = match.group(1)
    if hash:
        return f"{_BASE_URL}/uploads/short-url/{hash}"
    return ""


def fetch(url: str) -> str | None:

    batch = DiscourseProcessor.transform_to_url_batch(url)

    md_url = batch.raw_url

    result = DiscourseProcessor.get_markdown_from_url(md_url)

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
    lock_file = acquire_lock()
    try:
        main()
    finally:
        lock_file.close()
