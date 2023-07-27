#!/usr/bin/sh
systemd-inhibit --what=handle-suspend-key:handle-power-key:handle-hibernate-key --who=gamescope-session --why="gamescope-session handles power button events" sleep infinity