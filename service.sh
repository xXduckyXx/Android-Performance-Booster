#!/system/bin/sh
# Ultimate Optimizer 3.0 – Multi‑Mode Runtime Logic
# Modes selected during flashing: A, B, C, D, E

MODDIR=${0%/*}
CONFIG_FILE="/data/adb/ultimate_optimizer/mode.conf"
LOGFILE="/data/adb/ultimate_optimizer/optimizer.log"
mkdir -p /data/adb/ultimate_optimizer

log(){ echo "[$(date '+%H:%M:%S')] $1" >> "$LOGFILE"; }

MODE="$(cat "$CONFIG_FILE" 2>/dev/null)"
[ -z "$MODE" ] && MODE="E"   # default

# =====================
# MODE DEFINITIONS
# =====================

apply_mode_A(){
  # FULL BEAST MODE — MAX Performance Always
  log "Applying MODE A – Full BEAST MODE (Max Performance Always)"
  # CPU Max
  for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
    [ -f "$cpu/scaling_max_freq" ] && cat "$cpu/cpuinfo_max_freq" > "$cpu/scaling_max_freq" 2>/dev/null
    [ -f "$cpu/scaling_min_freq" ] && cat "$cpu/cpuinfo_min_freq" > "$cpu/scaling_min_freq" 2>/dev/null
  done
  # GPU Max
  [ -d /sys/class/kgsl/kgsl-3d0 ] && {
    echo 0 > /sys/class/kgsl/kgsl-3d0/min_pwrlevel 2>/dev/null
    echo 0 > /sys/class/kgsl/kgsl-3d0/max_pwrlevel 2>/dev/null
  }
  # Thermal relax
  for t in /sys/class/thermal/thermal_zone*/policy; do [ -f "$t" ] && echo "step_wise" > "$t" 2>/dev/null; done
}

apply_mode_B(){
  # FULL BATTERY SAVER MODE
  log "Applying MODE B – Full Battery Saver (Max Battery Life)"
  for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
    if [ -f "$cpu/scaling_max_freq" ]; then
      MAX=$(cat "$cpu/cpuinfo_max_freq")
      LIMIT=$((MAX * 65 / 100))
      echo "$LIMIT" > "$cpu/scaling_max_freq" 2>/dev/null
    fi
  done
  echo 1 > /sys/module/workqueue/parameters/power_efficient 2>/dev/null
  [ -d /sys/class/kgsl/kgsl-3d0 ] && {
    echo 6 > /sys/class/kgsl/kgsl-3d0/min_pwrlevel 2>/dev/null
    echo 6 > /sys/class/kgsl/kgsl-3d0/max_pwrlevel 2>/dev/null
  }
}

apply_mode_C(){
  # BALANCED MODE
  log "Applying MODE C – Balanced"
  for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
    if [ -f "$cpu/scaling_max_freq" ]; then
      MAX=$(cat "$cpu/cpuinfo_max_freq")
      LIMIT=$((MAX * 85 / 100))
      echo "$LIMIT" > "$cpu/scaling_max_freq" 2>/dev/null
    fi
  done
}

apply_mode_D(){
  # SMART AUTO MODE – Based on Screen State
  log "Applying MODE D – Smart Auto (Screen Based)"
  SCREEN=$(dumpsys power | grep 'Display Power' | grep -oE 'state=ON|state=OFF' | head -n1)
  case "$SCREEN" in
    *ON*) apply_mode_A;;
    *OFF*) apply_mode_B;;
  esac
}

apply_mode_E(){
  # YOUR CUSTOM MODE – Beast when charging, Saver unplugged
  log "Applying MODE E – Beast on charge, Battery saver unplugged"
  CHG=$(dumpsys battery | grep "AC powered:" | awk '{print $3}')
  if [ "$CHG" = "true" ]; then
    apply_mode_A
  else
    apply_mode_B
  fi
}

run_loop(){
  while true; do
    case "$MODE" in
      A) apply_mode_A;;
      B) apply_mode_B;;
      C) apply_mode_C;;
      D) apply_mode_D;;
      E) apply_mode_E;;
    esac
    sleep 30
  done
}

run_loop &