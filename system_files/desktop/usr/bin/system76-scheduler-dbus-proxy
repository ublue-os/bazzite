#!/bin/bash
DBUS_SERVICE="com.system76.Scheduler"
DBUS_PATH="/com/system76/Scheduler"
DBUS_INTERFACE="com.system76.Scheduler"
DBUS_METHOD="SetForegroundProcess"
dbus-monitor "destination=$DBUS_SERVICE,path=$DBUS_PATH,interface=$DBUS_INTERFACE,member=$DBUS_METHOD" | 
  while true; do 
    read method call time sender _ dest serial path interface member
    read type pid
    [ "$member" = "member=$DBUS_METHOD" ] && qdbus --system $DBUS_SERVICE $DBUS_PATH $DBUS_INTERFACE.$DBUS_METHOD $pid
  done
