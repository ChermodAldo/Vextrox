C="[ ? ]" # Checking
P="[ - ]" # Processing
S="[ > ]" # Started
F="[ + ]" # Success
E="[ ! ]" # Error
package_name="$1"
prop="$2"
v="$3"
shellVex="$4"
Vextrox="$5"
a="$6"
s="$7"
v="$8"
x() {
echo ""
exit 0
}
if ! command -v dumpsys > /dev/null; then
echo "$E Command dumpsys not found" && x
fi
Vr=$(dumpsys package "$v" | grep versionName | awk -F= '{print $2}')
# Inspiration @FahrezOne
close() {
ignore_list=()
while IFS= read -r line; do
if [[ "$line" == No_StopApp=* ]]; then
ignore_list+=("${line#No_StopApp=}")
fi
done < "$prop"
for All_package in $(cmd package list packages -3 | awk -F':' '{print $2}'); do
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
cache_path="/storage/emulated/0/Android/data/${All_package}/cache"
if [ -d "$cache_path" ]; then
rm -rf "$cache_path" > /dev/null 2>&1
fi
am force-stop "$All_package" > /dev/null 2>&1
cmd activity force-stop "$All_package" > /dev/null 2>&1
cmd activity kill "$All_package" > /dev/null 2>&1
am kill "$All_package" > /dev/null 2>&1
am kill-all "$All_package" > /dev/null 2>&1
fi
done
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
if [ -z "$package_name" ]; then 
echo "$C Package name not entered." && x 
fi
if [ -f "$prop" ]; then 
echo -e "$S Vextrox is detected." && sleep 1 
echo -e "$C Vextrox [ $Vr ] detected." && sleep 3 
echo -e "$P Optimizing Vextrox." && sleep 1 && close 
echo -e "$S Vextrox is Now Active." && sleep 2 && Vxt 
echo -e "$F Opening Vextrox - [ Connect Now ]." && sleep 1 
am start -n "${v}/${Vextrox}" --es "VEXTROX" "${shellVex}" > /dev/null 2>&1 
Opening 
else 
echo "$E ActivityManager & PackageManager not Permitted."
fi
