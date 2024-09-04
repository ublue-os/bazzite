<!-- ANCHOR: METADATA -->
<!--{"url_discourse": "https://universal-blue.discourse.group/docs?topic=2658", "fetched_at": "2024-09-03 16:43:04.885968+00:00"}-->
<!-- ANCHOR_END: METADATA -->

# Steam Logs

If you encounter issues with a game launching on Steam:

1. Open the game's properties and **enter this launch option**:
`PROTON_LOG=1 %command%`

2. Launch the game

A log file should appear in your Home directory named after the game's application ID number.

# Native Linux Port Versus Windows Version
Some Linux ports may have missing functionality or worse performance than on the Windows version running through Proton.  However, there are scenarios where using the native port exclusively is your only option, and may even be desirable.

# Valve/Source Engine Games Problems

>**Note**: This only applies to specific games running on the [Source engine](https://www.pcgamingwiki.com/wiki/Engine:Source).

## Audio & Custom Content Bugs

>**Attention**: Do **not** attempt to follow this workaround until you run into issues with audio or the specific scenario mentioned below regarding *Left 4 Dead 2*.

Missing voice lines or custom content not loading in Source games?  SELinux is blocking MP3 decoding and other middleware because it [executes heap memory](https://github.com/ValveSoftware/steam-for-linux/issues/43).  

This has also been confirmed to cause issues joining and hosting custom maps in *Left 4 Dead 2*.

>**Note**: Configuring SELinux is intended for advanced users and if used irresponsibly can break other components in your system and weaken the security of your device.

**At your own risk**

1. Open a host terminal and **enter these 4 commands**:

```command
sudo su
```
```command
cd /tmp
```

```command
ausearch -c 'hl2_linux' --raw | audit2allow -M my-hl2linux
```

```command
semodule -X 300 -i my-hl2linux.pp
```

2. Reboot your device

### If you want to undo this change eventually:

>Disable **or** remove the module.

#### Disable it:

```command
semodule -X 300 -d my-hl2linux
```

#### Remove and delete it:

```command
semodule -X 300 -r my-hl2linux
```

The `.pp` file should be in `/root` if you want to remove that.

## Source Games Not Launching

If a 32-bit Source 1 engine game is not opening due to [tmalloc libraries issues](https://github.com/ValveSoftware/csgo-osx-linux/issues/3229), then open a host terminal and **enter**:

1. Add the following as a **launch option** to the affected game in Steam:
```command
LD_PRELOAD=/usr/lib/libtcmalloc_and_profiler.so.4 %command%
```
2. Delete `libtcmalloc_minimal.so.x` in the game's bin folder if present.

If this fails to fix it, then try forcing Proton Experimental in the game's properties.

<hr>

**Documentation Contributors**: [M2](https://github.com/m2Giles)

[**<-- Back to Gaming Guide**](https://universal-blue.discourse.group/docs?topic=31)