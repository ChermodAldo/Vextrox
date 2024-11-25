#!/bin/bash
package_name="$1"
sleep 1
echo ""
echo "[ √ ] Package -> $package_name"
tuning=$(getprop debug.performance.tuning)

if [ "$tuning" == "1" ]; then
  echo "[ ! ] Performance tuning already enabled"
else
  echo "[ √ ] Enabling performance tuning"
  setprop debug.performance.tuning 1
fi
am force-stop "$package_name"
echo ""

props() {
  setprop debug.gr.numframebuffers 5
  setprop debug.composition.type c2
  setprop debug.egl.swapinterval 1
  settings put system game_mode 2
  setprop debug.egl.hw 1
  setprop debug.sf.hw 1
  setprop debug.egl.sync 0
  setprop debug.performance_schema 1
  setprop debug.performance_schema_max_memory_classes 387
}

plus() {
  device_config put game_overlay "$package_name" mode=2,renderer=skiagl,downscaleFactor=0.7,fps=90
  cmd game set --mode performance --downscale 0.7 --fps 90 --user 0 "$package_name"
  cmd power set-fixed-performance-mode-enabled true
  cmd power set-adaptive-power-saver-enabled false
  cmd thermalservice override-status 0
  cmd shortcut reset-throttling "$package_name"
  cmd game mode 2 "$package_name"
  cmd package compile -m speed-profile -f "$package_name" -r --secondary-dex
  cmd activity kill-all
  dumpsys deviceidle whitelist +"$package_name"
}

cprops() {
  props
  plus
}

cprops > /dev/null 2>&1 &

echo ""
echo "    >>>>>[ Vex - Boost X Vextrox ]<<<<<"
sleep 1
echo "====================================== "
echo ""
sleep 1
echo "Developer : @XGoost"
sleep 0.5
echo "Thanks to : @Chermodsc"
sleep 0.5
echo "Version Module : 3.0"
sleep 0.5
echo "𝕋𝕪𝕡𝕖 𝕄𝕠𝕕𝕦𝕝𝕖 ➤ [ Non Root! ]"
sleep 0.5
sleep 1
echo ""
echo "====================================== "
echo ""
echo "█░█ █▀▀ ▀▄▀ ▄▄ █▄▄ █▀█ █▀█ █▀ ▀█▀"
echo "▀▄▀ ██▄ █░█ ░░ █▄█ █▄█ █▄█ ▄█ ░█░"

sleep 3

basePath=$(dirname "$0")
sh "${basePath}/VxCode/VexShell.sh" "$1" "$basePath"
