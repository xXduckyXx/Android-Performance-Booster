#!/system/bin/sh
# Ultimate Optimizer 3.0 – Multi‑Mode Runtime Logic

MODDIR=${0%/*}
CONFIG_FILE="/data/adb/ultimate_optimizer/mode.conf"
LOGFILE="/data/adb/ultimate_optimizer/optimizer.log"
mkdir -p /data/adb/ultimate_optimizer

log() { 
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE" 
}

# Get mode with default
MODE="$(cat "$CONFIG_FILE" 2>/dev/null || echo "E")"

# Wait for boot completion
until [ "$(getprop sys.boot_completed)" = "1" ]; do
  sleep 5
done

# Additional delay for system stability
sleep 30

log "Ultimate Optimizer started with mode: $MODE"

# =====================
# MODE DEFINITIONS
# =====================

apply_mode_A() {
  log "Applying MODE A – Full BEAST MODE (Max Performance Always)"
  
  # CPU Max frequencies
  for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
    [ -d "$cpu" ] || continue
    if [ -f "$cpu/scaling_max_freq" ] && [ -f "$cpu/cpuinfo_max_freq" ]; then
      cat "$cpu/cpuinfo_max_freq" > "$cpu/scaling_max_freq" 2>/dev/null
    fi
    if [ -f "$cpu/scaling_min_freq" ] && [ -f "$cpu/cpuinfo_min_freq" ]; then
      cat "$cpu/cpuinfo_min_freq" > "$cpu/scaling_min_freq" 2>/dev/null
    fi
  done
  
  # GPU Max (Adreno)
  if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
    echo "performance" > /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null
    echo 0 > /sys/class/kgsl/kgsl-3d0/min_pwrlevel 2>/dev/null
    echo 0 > /sys/class/kgsl/kgsl-3d0/max_pwrlevel 2>/dev/null
  fi
  
  # I/O Scheduler to noop for performance
  for queue in /sys/block/*/queue; do
    [ -f "$queue/scheduler" ] && echo "noop" > "$queue/scheduler" 2>/dev/null
  done
}

apply_mode_B() {
  log "Applying MODE B – Full Battery Saver (Max Battery Life)"
  
  # CPU limit to 65%
  for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
    [ -d "$cpu" ] || continue
    if [ -f "$cpu/scaling_max_freq" ] && [ -f "$cpu/cpuinfo_max_freq" ]; then
      MAX=$(cat "$cpu/cpuinfo_max_freq")
      LIMIT=$((MAX * 65 / 100))
      echo "$LIMIT" > "$cpu/scaling_max_freq" 2>/dev/null
    fi
  done
  
  # Power efficient workqueue
  [ -f "/sys/module/workqueue/parameters/power_efficient" ] && 
    echo "Y" > /sys/module/workqueue/parameters/power_efficient 2>/dev/null
  
  # GPU Power save
  if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
    echo "msm-adreno-tz" > /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null
    echo 6 > /sys/class/kgsl/kgsl-3d0/min_pwrlevel 2>/dev/null
    echo 6 > /sys/class/kgsl/kgsl-3d0/max_pwrlevel 2>/dev/null
  fi
  
  # I/O Scheduler to cfq for battery
  for queue in /sys/block/*/queue; do
    [ -f "$queue/scheduler" ] && echo "cfq" > "$queue/scheduler" 2>/dev/null
  done
}

apply_mode_C() {
  log "Applying MODE C – Balanced"
  
  # CPU limit to 85%
  for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
    [ -d "$cpu" ] || continue
    if [ -f "$cpu/scaling_max_freq" ] && [ -f "$cpu/cpuinfo_max_freq" ]; then
      MAX=$(cat "$cpu/cpuinfo_max_freq")
      LIMIT=$((MAX * 85 / 100))
      echo "$LIMIT" > "$cpu/scaling_max_freq" 2>/dev/null
    fi
  done
  
  # Balanced GPU
  if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
    echo "msm-adreno-tz" > /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null
    echo 3 > /sys/class/kgsl/kgsl-3d0/min_pwrlevel 2>/dev/null
    echo 0 > /sys/class/kgsl/kgsl-3d0/max_pwrlevel 2>/dev/null
  fi
}

apply_mode_D() {
  log "Applying MODE D – Smart Auto (Screen Based)"
  
  SCREEN_STATE=$(dumpsys display | grep "mScreenState" | head -n1)
  case "$SCREEN_STATE" in
    *ON*)
      apply_mode_A
      ;;
    *OFF*)
      apply_mode_B
      ;;
    *)
      apply_mode_C
      ;;
  esac
}

apply_mode_E() {
  log "Applying MODE E – Beast on charge, Battery saver unplugged"
  
  POWER_STATE=$(dumpsys battery | grep -E "AC powered:|USB powered:" | grep "true")
  if [ -n "$POWER_STATE" ]; then
    apply_mode_A
  else
    apply_mode_B
  fi
}

# Main optimization loop
while true; do
  case "$MODE" in
    "A") apply_mode_A ;;
    "B") apply_mode_B ;;
    "C") apply_mode_C ;;
    "D") apply_mode_D ;;
    "E") apply_mode_E ;;
    *) apply_mode_E ;;
  esac
  
  sleep 30
done