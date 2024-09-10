# Contributing to Bazzite MkDocs documentation

## Introduction

This is a guide that will show you how to write, or transcribe documentation from Discourse forums (https://universal-blue.discourse.group/) to MkDocs pages.

## What is MkDocs

> _MkDocs is a fast, simple and downright gorgeous static site generator that's geared towards building project documentation. Documentation source files are written in Markdown, and configured with a single YAML configuration file._
>
> Source ~ https://www.mkdocs.org/

**TL;DR**: Its a fancy way tool that allows us to create a documentation website with basic [Markdown](https://commonmark.org/help/).

The essential part that can't be missing in a mdBook is the `mkdocs.yml` file.

`mkdocs.yml` acts as our main configuration file. One of its main tasks is to configure the **Table of Contents** and to configure translation files.

## Setup MkDocs tooling

> ⚠️ WARNING ⚠️
>
> This step is **required** in order to setup previews of the resulting MkDocs

To install our dependencies, run this:

```sh
bash docs/utils/install-deps.sh
```

<details>
<summary>
<big>Dependencies list</big><br>
<sup>Ignore if using install-deps.sh</sup>
</summary>

- [Poetry](https://python-poetry.org/) (can be installed with Homebrew)
- [Just](https://just.systems/man/en/) (preinstalled in all [Universal Blue](https://universal-blue.org/) images)

</details>

You will need other tools as well, like:

- A markdown compatible code editor (ex.: **Visual Studio Code**)
- **git** (comes preinstalled in most Linux distributions)

### 1. Create the markdown file where we will store our document.

   > ⚠️ WARNING
   >
   > Just remember, ⚠️**DO NOT USE SPACES IN THE FILE NAME**⚠️. Is really important, spaces in filenames is going to bit us later in a future.
   > Instead, use underscores `_`

### 2. Set a proper page name

You can add more explicit page titles (used by the browser tab names) by using YAML metadata.

Adding this at the start of the markdown file would change the tab name to "Hello world":

```yaml
---
title: "Hello world"
---
```

## Translate documentation

Translating documentation is as straightfoward as can be.
Lets say we want to translate `Homebrew.md` to Spanish. All what you would have to do is make a copy of the file with the name `Homebrew.es.md` and start translating.

Perhaps you can't see your translation with `just mkdocs serve`.
Chances are we need to configure MkDocs to do so.

Open `mkdocs.yml`, look for the field `languages`, should look something like this:

```yaml
languages:
   - locale: en
      default: true
      name: English
      build: true
```

Add your language, in our case is Spanish:

```yaml
languages:
   - locale: en
      default: true
      name: English
      build: true
   - locale: es
      name: Spanish
      build: true
```

MkDocs should show a language selector in the top bar.
