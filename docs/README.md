---
author: @Zeglius
---

# Contributing to Bazzite mdBook documentation

## Introduction

This is a guide that will show you:

- How to write new documentation pages in mdBooks.
- How to transcribe documentation, from Discourse forums (https://universal-blue.discourse.group/) to mdBook pages.

## Brief explanation in how to work with mdBook

> _mdBook is a command line tool to create books with Markdown. It is ideal for creating product or API documentation, tutorials, course materials or anything that requires a clean, easily navigable and customizable presentation_
>
> Source ~ https://rust-lang.github.io/mdBook/

**TL;DR**: Its a fancy way tool that allows us to create a documentation website with basic [Markdown](https://commonmark.org/help/).

---

The essential part that cant be missing in a mdBook is the `SUMMARY.md` file.

```md
<!-- Example of SUMMARY.md contents -->

# General

- [📜 Bazzite's README](Bazzite_README.md)
- [❓️ FAQ](General/FAQ.md)
- [📖 Installation Guide](General/Installation_Guide/index.md)
- [📝 Desktop Environment Tweaks](General/Desktop_Environment_Tweaks.md)
- [🤝 Contributing to Bazzite](General/Contributing_to_Bazzite.md)
- [🎲 Gaming](Gaming/index.md)
  - [Game Launchers](Gaming/Game_Launchers.md)

# Steam Gaming Mode / Handheld & HTPC Hardware

- [📺️ Steam Gaming Mode Overview](Handheld_and_HTPC_edition/Steam_Gaming_Mode/index.md)
  - [Change Physical Keyboard Layout for Steam Gaming Mode](Handheld_and_HTPC_edition/Change_Physical_Keyboard_Layout_for_Steam_Gaming_Mode.md)
```

`SUMMARY.md` acts not only as a nice looking table of contents, but as indexer as well.

**If a page is not listed in `SUMMARY.md`, it wont be included in the mdBook**\*

<small>\* Just so you are aware </small>

---

## Transcribe Discourse docs to mdBooks

Requirements:

- Markdown compatible code editor (ex.: Visual Studio Code)
- mdBook (can be installed with Homebrew\*)
- Git

<small>\* If you are using Bazzite or [similar](https://universal-blue.org/), chances are that you already have it installed.</small>

---

Best way to learn is with a real life example. We will transcribe

### 1. Basic preparation

We will start with getting our utilities ready:

1. A web browser with the Discourse doc page we want to transcribe. We will use <https://universal-blue.discourse.group/docs?topic=2743> for this example.
2. Our code editor.
3. A terminal open in the `docs` directory

   ```sh
   $ cd docs
   ```

   Get sure we have `fetch_discourse_md.py` in there, we will need it

   ```sh
   $ ls ./fetch_discourse_md.py
   ./fetch_discourse_md.py
   ```

### 2. Copy the post

`fetch_discourse_md.py` is your friend for this task.

1. Copy the URL of the document
2. In the terminal, pass the URL to `fetch_discourse_md.py`

   ```sh
   $ ./fetch_discourse_md.py "https://universal-blue.discourse.group/docs?topic=2743" | wl-copy
   ```

   Normally, `fetch_discourse_md.py` would dump the resulting markdown doc in the terminal output, with `wl-copy` we store it in our clipboard for now.

3. Create the markdown file where we will store our document. The title of the post is "_Dual Boot Preliminary Setup and Post-Setup Guide_", so somewhere under "Advanced" should be fitting.

   > ⚠️ WARNING
   >
   > Just remember, ⚠️**DO NOT USE SPACES IN THE FILE NAME**⚠️. Is really important, spaces in filenames is going to bit us later in a future.
   > Instead, use underscores `_`

   ![](./src/img/doc_guide_filename.jpg)

### 4. Paste the document in the file

![](./src/img/doc_guide_paste.jpg)

### 5. Rewrite URLs

We are almost done. The problem is `fetch_discourse_md.py` only will give us a dumped version of the Discourse document.

There is posibly URLs that are pointing to other documentation posts in Discourse that we might have already in our mdBook.

![](./src/img/doc_guide_discourse_url.jpg)

The url in the image above is pointing to the _Steam Gaming Mode Overview (Handheld/HTPC)_ post.
At the time of writting this, we have that post avaliable in our mdBook, so we can simply replace that URL with ours

![](./src/img/doc_guide_rewrite_url.jpg)

In our case, the post is located in `../Handheld_and_HTPC_edition/Steam_Gaming_Mode/index.md`

### 6. Link back in `SUMMARY.md`

We can check how our post looks in mdBook, run in the terminal

```sh
mdbook serve --open
```

Aaaaand... _Where_?

![](./src/img/doc_guide_where_did_go.jpg)

If you read [the brief explanation](#brief-explanation-in-how-to-work-with-mdbook), you will read about `SUMMARY.md`.

Lets add our file there.

![](./src/img/doc_guide_add_summary.jpg)

Aaaand... There you are!

![](./src/img/doc_guide_there_you_are.jpg)

## Write new documentation

WIP
