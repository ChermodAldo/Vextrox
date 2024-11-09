if which su > /dev/null 2>&1; then
    status="Advance"
else
    status="Simple"
fi
package_name="$1"
echo "  _          _"
echo " / \        / \ "
echo "/  /\      /\  \ "
echo "  /  \    /  \ "
echo "  \   \  /   / "
echo "   \   \/   / "
echo "    \      / "
echo "     \    / "
echo "      \  / "
echo "       \/ "
echo "\      /\      / "
echo " \    /  \    / "
echo "  \  /    \  / "
echo "   \/      \/ "
echo ""
echo "[ + ] Optimize app: $package_name"
display_info=$(dumpsys display)

if which su > /dev/null 2>&1; then
    status="Advance"
else
    status="Simple"
fi

if [ -z "$render" ]; then
    if [ -n "$(getprop ro.hardware.vulkan)" ]; then
        render="skiagl"
    elif [ -n "$(getprop ro.hardware.opengl)" ]; then
        render="opengl"
    else
        render="vulkan"
    fi
fi

setprop debug.hwui.renderer "$render"
echo "[ + ] Auto render: $render"
sleep 1

fps=$(echo "$display_info" | grep -oE 'fps=[0-9.]+' | awk -F '=' '{printf "%d\n", $2+0}' | head -n 1)
am force-stop "$package_name"
echo "[INFO] Setting game FPS to $fps"
echo "[ - ] Setting game overlay"
device_config put game_overlay "$package_name" mode=2,downscaleFactor=0.7,fps=$fps
if [ $? -eq 0 ]; then
  echo "[ - ] Game overlay set successfully"
else
  echo "[ x ] Failed to set game overlay"
fi
sleep 1

echo "[ - ] Setting Activity Manager Focus"
cmd settings put global activity_manager_constants background_settle_time=0,content_provider_retain_time=0,fgservice_min_report_time=0,fgservice_min_shown_time=0,fgservice_screen_on_after_time=0,fgservice_screen_on_before_time=0,full_pss_lowered_interval=0,full_pss_min_interval=0,gc_min_interval=0,gc_timeout=0,max_cached_processes=0,memory_info_throttle_time=0,power_check_interval=0,power_check_max_cpu_1=0,power_check_max_cpu_2=0,power_check_max_cpu_3=0,power_check_max_cpu_4=0,process_start_async=0,service_bg_activity_start_timeout=0,service_bg_start_timeout=0,service_crash_max_retry=0,service_crash_restart_duration=0,service_max_inactivity=0,service_min_restart_time_between=0,service_reset_run_duration=0,service_restart_duration=0,service_restart_duration_factor=0,service_usage_interaction_time=0,top_to_fgs_grace_duration=0,usage_stats_interaction_interval=0
if [ $? -eq 0 ]; then
  echo "[ - ] Activity Manager Focus successfully set"
else
  echo "[ x ] Failed to set Activity Manager Focus"
fi
sleep 1

echo "[ - ] Configuring game settings"
cmd game set --mode 2 --downscale 0.7 --fps $fps $package_name
if [ $? -eq 0 ]; then
  echo "[ - ] Game settings configured successfully"
else
  echo "[ x ] Failed to configure game settings"
fi
sleep 1

echo "[ - ] Enabling fixed performance mode"
cmd power set-fixed-performance-mode-enabled true
cmd power set-adaptive-power-saver-enabled false
if [ $? -eq 0 ]; then
  echo "[ - ] Fixed performance mode enabled successfully"
else
  echo "[ x ] Failed to enable fixed performance mode"
fi
sleep 1

echo "[ - ] Setting game downscale"
cmd game downscale 0.7 "$package_name" > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "[ - ] Game downscale set successfully"
else
  echo "[ - ] Game downscale set successfully"
fi
sleep 1
echo "[ - ] Applying touch settings"
  #Info ERIN ACE
  settings put system touch.pressure.scale 0.001
  if [ $? -eq 0 ]; then
    echo "[ - ] touch.pressure.scale successfully"
  else
    echo "[ x ] Failed to apply touch.pressure.scale"
  fi

  settings put system touch.size.calibration geometric
  if [ $? -eq 0 ]; then
    echo "[ - ] touch.size.calibration successfully"
  else
    echo "[ x ] Failed to apply touch.size.calibration"
  fi

  settings put system touch.pressure.calibration amplitude
  if [ $? -eq 0 ]; then
    echo "[ - ] touch.pressure.calibration successfully"
  else
    echo "[ x ] Failed to apply touch.pressure.calibration"
  fi

  settings put system touch.size.scale 1
  if [ $? -eq 0 ]; then
    echo "[ - ] touch.size.scale successfully"
  else
    echo "[ x ] Failed to apply touch.size.scale"
  fi

  settings put system touch.distance.scale 0
  if [ $? -eq 0 ]; then
    echo "[ - ] touch.distance.scale successfully"
  else
    echo "[ x ] Failed to apply touch.distance.scale"
  fi
  sleep 1

if [ "$(getprop dalvik.vm.usejit)" ]; then
  echo "[ - ] Enabling JIT"
  pm compile -m speed-profile -f "$package_name" > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "[ - ] Primary dex compiled successfully"
  else
    echo "[ x ] Failed to compile primary dex"
  fi
  sleep 1
echo "[ - ] Compiling secondary dex"
pm compile -m speed-profile --secondary-dex -f "$package_name" > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "[ - ] Secondary dex compiled successfully"
else
  echo "[ x ] Failed to compile secondary dex"
fi

echo "[ - ] Reconciling secondary dex files"
pm reconcile-secondary-dex-files -f "$package_name"
if [ $? -eq 0 ]; then
  echo "[ - ] Secondary dex reconciled successfully"
else
  echo "[ x ] Failed to reconcile secondary dex"
fi

echo "[ - ] Compiling layouts"
pm compile --compile-layouts -f "$package_name" > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "[ - ] Layouts compiled successfully"
else
  echo "[ x ] Failed to compile layouts"
fi
fi

set_debug_properties() {
  setprop debug.sf.hw 1
  setprop debug.egl.hw 1
  setprop debug.egl.sync 0
  setprop debug.egl.swapinterval 0
  setprop debug.composition.type gpu
}

configure_system() {
  set_debug_properties
  settings put global window_animation_scale 0.5
  settings put global transition_animation_scale 0.5
  settings put global animator_duration_scale 0.5
}


configure_system
sleep 1
echo "[ > ] Execution Mode : $status"
echo "[ > ] Execution VexShell"
echo ""
echo "Opening Vextrox menu.."
basePath=$(dirname "$0")
sh "${basePath}/VxCode/VexShell.sh" "$1" "$basePath"
