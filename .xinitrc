#!/bin/sh

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
xsetroot -cursor_name left_ptr
setxkbmap -layout "br"

export KDE_FULL_SESSION=true

#pkill compton; sleep 2 && compton -cb -F -I 0.06 -O 0.06 -e 0.9

pkill cairo-compmgr; sleep 2 && cairo-compmgr &
ck-launch-session dbus-launch  --exit-with-session xmonad
