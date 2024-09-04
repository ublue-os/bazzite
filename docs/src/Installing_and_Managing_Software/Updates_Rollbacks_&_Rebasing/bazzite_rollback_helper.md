<!-- ANCHOR: METADATA -->
<!--{"url_discourse": "https://universal-blue.discourse.group/docs?topic=2647", "fetched_at": "2024-09-03 16:43:17.164020+00:00"}-->
<!-- ANCHOR_END: METADATA -->

![Bazzite Rollback Helper Command|636x500](https://universal-blue.discourse.group/uploads/short-url/oMMAp6yNxPPO7XERGtsJ5lPX5Qb.png)

>**Note**: Read the [rollback](https://universal-blue.discourse.group/docs?topic=2644) and [rebasing](https://universal-blue.discourse.group/docs?topic=2646) guides to understand the terms and what they do.

A command-line utility that assists with **rollbacks**, **rebasing**, and **information on your current image**.

Open a host terminal and **enter**:
```command
bazzite-rollback-helper
```
# Options are available to the user:
  - `list` = List images from the last 90 days that can rebased to.
  - `rollback` = Rollback to the previous deployment on next reboot.
  - `current` = Show information about your current deployment and image.
  - `rebase` = Switch to another build, update branch, or a different Fedora image **at your own risk**.

# Video Guide

https://www.youtube.com/watch?v=XvljabnzgVo

> # Key Takeaways:
> **Updates**: Upgrades both system and installed software.
> **Rollbacks**: Return to a previous deployment after a bad system upgrade.
> **Rebasing**: Use the `bazzite-rollback-helper` command in the terminal.

<hr>

[**<-- Back to Updates, Rollback, and Rebasing Guide**](https://universal-blue.discourse.group/docs?topic=36)