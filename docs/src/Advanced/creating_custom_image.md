<!-- ANCHOR: METADATA -->
<!--{"url_discourse": "https://universal-blue.discourse.group/docs?topic=43", "fetched_at": "2024-09-03 16:43:11.309087+00:00"}-->
<!-- ANCHOR_END: METADATA -->

# Making your own image

**Containerfile template**: 
https://github.com/ublue-os/image-template
 
Sometimes you don't want to make a whole new image from scratch, you just want to change some things without too much extra work. Sometimes it's nicer to derive from images that more end-user focused like [Bazzite](https://github.com/ublue-os/bazzite), [Bluefin](https://github.com/ublue-os/bluefin), and [Aurora](https://getaurora.dev/).
 
## Use Cases
 
- You want to help development by being able to test your contributions prior to submiting to the community.
    - Hardware enablement, experimental features, confirming fixes ahead of merge
- You want to change out applications and other default choices but want to stick close to Bazzite/Bluefin to get improvements automatically
    - For example, Bluefin DX has Visual Studio baked into the image. If you want the rest of it but don't use vscode you could replace it or remove it. 
    - You need to layer something like VPN software that has to be on an image but you don't want to maintain your own standalone image. (Deriving off of others is always easier, that's why we made this project)
    - You want a personal-use image with config and software changes, but also want to benefit from work being completed upstream.
 
[`ublue-os/main`](https://github.com/ublue-os/main) are used to generate base images of everything, so are usually not good candidates for this unless you are familiar with git, containers, and GitHub Actions.

<hr>

**See also**: [Community Created Custom Images](https://universal-blue.discourse.group/docs?topic=340)