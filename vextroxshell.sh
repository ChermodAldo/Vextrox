local C="[ ? ]" # Checking
local P="[ - ]" # Processing
local S="[ > ]" # Started
local F="[ + ]" # Success
local E="[ ! ]" # Error
local package_name="$1"
local prop="$2"
local v="$3"
local shellVex="$4"
local Vextrox="$5"
local a="$6"
local s="$7"
local Vr=$(dumpsys package "$v" | grep versionName | awk -F= '{print $2}')
jlocal packages_list="/storage/emulated/0/VextroxExecution/VxList/packages.list"
local name_package=$(cat "$packages_list")
x() {
echo ""
exit 0
}
if ! command -v dumpsys > /dev/null; then
echo "$E Command dumpsys not found" && x
fi
# Inspiration @FahrezOne
close() {
ignore_list=()
while IFS= read -r line; do
if [[ "$line" == No_StopApp=* ]]; then
ignore_list+=("${line#No_StopApp=}")
fi
done < "$prop"
for All_package in $(cat $packages_list); do
should_ignore=0
for ignore in "${ignore_list[@]}"; do
if [[ "$All_package" == "$ignore" ]]; then
should_ignore=1
break
fi
done
if [[ "$should_ignore" -eq 1 || "$All_package" == "$b" || "$All_package" == "$t" || "$All_package" == "$s" || "$All_package" == "$v" || "$All_package" == "$a" || "$All_package" == "$package_name" ]]; then
continue
else
local cache_path="/storage/emulated/0/Android/data/${All_package}/cache/" ;rm -rf "$cache_path" > /dev/null 2>&1
am force-stop "$All_package"
cmd activity force-stop "$All_package" > /dev/null 2>&1
cmd activity kill "$All_package" > /dev/null 2>&1
am kill "$All_package" > /dev/null 2>&1
am kill-all "$All_package" > /dev/null 2>&1
clear > /dev/null 2>&1 &
fi
done
}
clear() {
cmd stats clear-puller-cache
logcat -c
find /sdcard/Android/data/*/cache/* -delete
am clear-watch-heap -a
simpleperf --log fatal --log-to-android-buffer 0
sm fstrim
cmd activity clear-debug-app
}
Notification() {
cmd notification post -S messaging --conversation "Vextrox" --message "[ $package_name ]: Is Running - Vextrox Shell" "VextroxShell" "Active successful" > /dev/null 2>&1 &
}
Opening() {
while true; do
if pidof "$package_name" >/dev/null; then
Notification
break
fi
sleep 5
done
}
Vxt() {
formatted_package_name="$package_name"
if grep -q '^package_name=' "$prop"; then
sed -i "s/^package_name=.*/package_name=$formatted_package_name/" "$prop"
else
echo "package_name=$formatted_package_name" >> "$prop"
fi
updated_package_name=$(grep '^package_name=' "$prop" | awk -F '=' '{print $2}')
}
if [ -n "$package_name" ]; then
if echo $name_package | grep -qw "$package_name"; then
if [ -f "$prop" ]; then 
echo -e "$S Vextrox is detected" && sleep 1
echo -e "$C Vextrox [ $Vr ] detected" && sleep 3 
echo -e "$P Optimizing Vextrox" && close 
echo -e "$S Vextrox is Now Active" && Vxt 
echo -e "$F Opening Vextrox - [ Connect Now ]" && sleep 1 
am start -n "${v}/${Vextrox}" --es "VEXTROX" "${shellVex}" > /dev/null 2>&1 
Opening 
else 
echo "$E ActivityManager & PackageManager not Permitted."
fi
else
echo "$E Package not detected or installed" && x
fi
else
echo "$C Package name not entered" && x 
fi
