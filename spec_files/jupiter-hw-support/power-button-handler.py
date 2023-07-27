#!/bin/env python3 -u

import evdev
import threading
import os
import sys
import subprocess
import daemon
import psutil

powerbuttondev = None

devices = [evdev.InputDevice(path) for path in evdev.list_devices()]
for device in devices:
	if device.phys == "isa0060/serio0/input0":
		powerbuttondev = device;
	else:
		device.close()

longpresstimer = None

systemd-inhibit = ['systemd-inhibit',
	'--what=handle-power-key:handle-suspend-key:handle-hibernate-key',
	'sleep',
	'infinity']

def inhibit():
	for proc in psutil.process_iter():
		if systemd-inhibit == proc.cmdline():
			return

	print ( "Starting inhibitor" )
	with daemon.DaemonContext():
		subprocess.call(systemd-inhibit)

def uninhibit():
	print ( "Stopping inhibitor" )
	subprocess.call(['pkill', '-f', ' '.join(systemd-inhibit)])

def longpress():
	os.system( "~/.steam/root/ubuntu12_32/steam -ifrunning steam://longpowerpress" )
	global longpresstimer
	longpresstimer = None

if powerbuttondev != None:
	inhibit()

	for event in powerbuttondev.read_loop():
		if event.type == evdev.ecodes.EV_KEY and event.code == 116: # KEY_POWER
			if event.value == 1:
				longpresstimer = threading.Timer( 1.0, longpress )
				longpresstimer.start()
			elif event.value == 0:
				if longpresstimer != None:
					os.system( "~/.steam/root/ubuntu12_32/steam -ifrunning steam://shortpowerpress" )
					longpresstimer.cancel()
					longpresstimer = None

	powerbuttondev.close()
	uninhibit()
	exit()

print ( "power-button-handler.py: Can't find device for power button!" )
