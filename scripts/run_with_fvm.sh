#!/usr/bin/env zsh
# Interactive script to list emulators and physical devices,
# select one, optionally launch emulator, and run Flutter via FVM.

set -e

print_usage() {
  cat << 'EOF'
Usage: scripts/run_with_fvm.sh [options]

Options:
  -r, --release      Build and run in release mode
  -w, --web          Run on web (if device selected is web)
  -h, --help         Show this help

Flow:
  1) Lists available Android emulators and connected devices
  2) You choose one target
  3) If emulator chosen and not running, it will be launched
  4) Runs `fvm flutter run` targeting the selection

Requires:
  - fvm installed and a Flutter version configured
  - Android SDK / AVD for emulators
EOF
}

MODE="debug"
while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--release)
      MODE="release"
      shift
      ;;
    -w|--web)
      MODE="web"
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      print_usage
      exit 1
      ;;
  esac
done

command -v fvm >/dev/null 2>&1 || { echo "Error: fvm not found in PATH"; exit 1; }

# Collect emulators
# Try to parse with bullet separator (newer flutter)
EMULATORS=$(fvm flutter emulators 2>/dev/null | grep "•" | awk -F '•' '{
  id=$1; gsub(/^[ \t]+|[ \t]+$/, "", id);
  name=$2; gsub(/^[ \t]+|[ \t]+$/, "", name);
  print id "|" name
}')

# If empty, try older format (ID - Name)
if [[ -z "$EMULATORS" ]]; then
  EMULATORS=$(fvm flutter emulators 2>/dev/null | sed -n 's/^\([^ ]\+\)\s\+-\s\(.*\)$/\1|\2/p')
fi

# Collect devices
# Parse lines with bullet separator
DEVICES=$(fvm flutter devices 2>/dev/null | grep "•" | awk -F '•' '{
  name=$1; gsub(/^[ \t]+|[ \t]+$/, "", name);
  id=$2; gsub(/^[ \t]+|[ \t]+$/, "", id);
  platform=$3; gsub(/^[ \t]+|[ \t]+$/, "", platform);
  print name "|" id "|" platform
}')

choices=()
if [[ -n "$EMULATORS" ]]; then
  while IFS='|' read -r id name; do
    choices+="emulator:$id|$name"
  done <<< "$EMULATORS"
fi
if [[ -n "$DEVICES" ]]; then
  while IFS='|' read -r name id platform; do
    choices+="device:$id|$name ($platform)"
  done <<< "$DEVICES"
fi

if [[ ${#choices[@]} -eq 0 ]]; then
  echo "No emulators or devices found."
  echo "- Create/start an emulator in Android Studio (Device Manager)"
  echo "- Or connect a physical device with USB debugging enabled"
  exit 1
fi

echo "Select a target to run:" 
idx=1
for c in "${choices[@]}"; do
  type=${c%%:*}
  rest=${c#*:}
  id=${rest%%|*}
  label=${rest#*|}
  printf "%2d) %-8s %-20s %s\n" "$idx" "$type" "$id" "$label"
  idx=$((idx+1))
done

read -r "selection?Enter number: "
if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
  echo "Invalid selection"; exit 1
fi

sel_index=$((selection-1))
if (( sel_index < 0 || sel_index >= ${#choices[@]} )); then
  echo "Selection out of range"; exit 1
fi

selected=${choices[$((sel_index+1))]}
type=${selected%%:*}
rest=${selected#*:}
id=${rest%%|*}
label=${rest#*|}

echo "Chosen: $type id=$id label=$label"

# If emulator selected, try to launch it
if [[ "$type" == "emulator" ]]; then
  echo "Launching emulator $id ..."
  fvm flutter emulators --launch "$id" || {
    echo "Failed to launch emulator $id"; exit 1; }
  echo "Waiting for device to be ready ..."
  # Wait until it appears in flutter devices
  for i in {1..20}; do
    if fvm flutter devices | grep -q "$id"; then
      break
    fi
    sleep 2
  done
fi

# Run according to mode
case "$MODE" in
  debug)
    echo "Running in debug mode on $id ..."
    exec fvm flutter run -d "$id"
    ;;
  release)
    echo "Building and installing release on $id ..."
    exec fvm flutter run --release -d "$id"
    ;;
  web)
    echo "Running web on $id ..."
    exec fvm flutter run -d "$id"
    ;;
  *)
    exec fvm flutter run -d "$id"
    ;;
esac
