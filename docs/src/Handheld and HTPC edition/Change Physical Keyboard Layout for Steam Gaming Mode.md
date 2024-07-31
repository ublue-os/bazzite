As of writing, gamescope-session has no way to change the physical keyboard layout and will default to the US layout.

If you want to change the layout for gamescope, you can set the environment variable `XKB_DEFAULT_LAYOUT=no` replacing `no` with the correct layout for you.
you can add this to `~/.config/environment.d/10-gamescope-session.conf`
If the file or folder does not exist... make them :magic_wand:

This works on desktop mode for things running in nested gamescope and also works for gamescope-session, but it has its own quirks (like `altgr+2` to write `@` on the norwegian layout will still not work, but the basic keyboard layout will always work, `altgr` is luckily not needed for normal typing on the norwegian layout, however `altgr` has been reported to work on the french layout, your mileage may vary)

<hr>

**Documentation Contributors**: [HikariKnight](https://github.com/HikariKnight)
