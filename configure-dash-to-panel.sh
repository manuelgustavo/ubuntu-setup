#!/bin/bash
#set -x
set -euo pipefail

dconf write /org/gnome/shell/extensions/dash-to-panel/trans-panel-opacity 0.4
dconf write /org/gnome/shell/extensions/dash-to-panel/trans-use-custom-bg false
dconf write /org/gnome/shell/extensions/dash-to-panel/trans-use-custom-opacity true
dconf write /org/gnome/shell/extensions/dash-to-panel/trans-use-dynamic-opacity false