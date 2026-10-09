#!/usr/bin/env bash
# Runs right after the Mac wakes from sleep (swayidle after-resume).

# Remember when we woke up, so the power-button press that woke the Mac
# doesn't immediately put it back to sleep (see power-button.sh)
date +%s > "${XDG_RUNTIME_DIR:-/tmp}/labwc-resumed-at"

# Make sure the screen is on (it may have been turned off by the idle timer)
wlopm --on '*' >/dev/null 2>&1
