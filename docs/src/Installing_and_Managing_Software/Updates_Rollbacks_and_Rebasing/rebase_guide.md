<!-- ANCHOR: METADATA -->
<!--{"url_discourse": "https://universal-blue.discourse.group/docs?topic=2646", "fetched_at": "2024-09-03 16:43:14.912897+00:00"}-->
<!-- ANCHOR_END: METADATA -->

![Docker's OCI Icon|200x200, 100%](../../img/Dockers_OCI_Icon.png)]

# What is Rebasing?

>**Attention**: Do **not** rebase between different desktop environments.

Rebasing allows users to switch to a different image **without** having to reinstall and lose personal files and application data. 

[**It is recommended to use the Bazzite Rollback Helper utility**](./bazzite_rollback_helper.md).

# Rebase Scenarios
- Rebase to specific images of older builds within the last 90 days if issues are occurring on the newest build of Bazzite.  
- Rebase to other Fedora Atomic Desktop images including other Bazzite images.
  - Do **not** rebase between different desktop environments.

# How do I swap between Bazzite (and other Fedora Atomic Desktop) images?

See what channel or build you are on by **entering this command in a host terminal**:
```command
rpm-ostree status
```
Check under "Deployments:" and the output should be similar to:

> **● ostree-image-signed:docker://ghcr.io/ublue-os/[*image*]:[*channel*]**

Switch to another Bazzite variant by entering the command for each specific image.

Open the terminal and **enter**:
```
rpm-ostree rebase <image>
```

**Example**:

```command
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/bazzite-deck:stable
```

For rebasing to the generic KDE Plasma version of the Handheld & HTPC image.

>**NOTE**: Rebasing between different desktop environments **may cause issues** and is **unsupported**.
    
# How do I change the Bazzite's update branch? (Stable, Testing, and Unstable)

There are 3 branches you can switch to:

- Stable (`:stable`)
  - Default branch that's used in normal Bazzite installations
- [Testing (`:testing`)](https://github.com/ublue-os/bazzite/compare/main...testing)
  - Get a sneak peak of future Bazzite builds before release
  - Bugs may frequently appear
  - Encouraged to rebase back to `:stable` after testing a major release
    -  It can be behind on certain updates for a long time
- Unstable (`:unstable`) **(DO NOT USE**)
  - **Not recommended**
  - Testing playground for developers/contributors
  - Can be **several months behind** compared to both `:stable` and `:testing` updates
  - Intended for testing desktop environments and other radically changed functionality to Bazzite for the future

Handheld/HTPC images can switch branches in `Settings > System > OS Update Channel` in Steam Gaming Mode.

If you enabled **advanced update channel**, then additional options will appear. The options map as the following:

```
Stable (:stable) 
Release Candidate (:testing)
Beta (:testing)
Beta Candidate (:unstable)
Main (:unstable)
```

For Desktop images, replacing `:stable` with `:testing` or `:unstable` to the end of the rebase command for your Bazzite image allows you to switch to the experimental branches (which may have frequent bugs.)

**Example**: 
```command
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/bazzite:testing
``` 
For the **testing** branch on the generic AMD/Intel Desktop image.

# Can I stay on a specific Fedora release?

>**Warning**: You will have to rebase back to `:stable` once you want to upgrade to the next Fedora version.

>**Note:** Switching to older Fedora versions will not bring new updates until you upgrade back to `:stable` and this also means **no security updates** for the time being.

**Yes**, but only if that version of Fedora is still currently supported upstream. 

- Replace `:stable` with the supported version of Fedora you would like to stay on.
- [Fedora Rawhide](https://docs.fedoraproject.org/en-US/releases/rawhide/) is **not** supported.

# Rebasing to older builds

>**Warning**: You will have to rebase back to `:stable` once you want to upgrade to the newest release. 

- Like rolling back to the previous Bazzite deployment, users can also rebase to a specific Bazzite builds that was were built within the last 90 days.
- All of your userdata will remain intact, but like how the warning indicates above, you will have to rebase manually back to `:stable` to update the system to receive the newest build.

View the list of available builds by **entering**:

```command
skopeo list-tags docker://ghcr.io/ublue-os/bazzite | grep -- "-stable-" | sort -rV
```

Rebasing to a specific build requires users to open a host terminal and  **enter**: 
```command
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/IMAGE-NAME:VERSION-YEARMONTHDAY
``` 
**Example**: 
```command
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/bazzite-deck:39-20240113
```
For the *Jan. 13th 2024* `bazzite-deck` (*Fedora 39*) build.

<hr>

[**<-- Back to Updates, Rollback, and Rebasing Guide**](./index.md)