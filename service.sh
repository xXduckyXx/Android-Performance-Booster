#!/system/bin/sh

# ==============================================
# ULTIMATE PERFORMANCE & BATTERY OPTIMIZER v2.0
# ==============================================
# Created by: xXduckyXx - 13 Year Old Developer
# Device: Samsung Galaxy S22 SM-S901B
# Android: 15 One UI 7
# Date: December 2025
# 
# 🌟 My first public release! Learning to code! 🌟
# ==============================================

MODDIR=${0%/*}
LOG_FILE="/data/media/0/optimizer_log.txt"
ANDROID_VERSION=$(getprop ro.build.version.sdk)
DEVICE_NAME=$(getprop ro.product.model)
BUILD_DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Cool banner for logs
print_banner() {
    echo "==============================================" >> $LOG_FILE
    echo "  ULTIMATE OPTIMIZER v2.0 - BY 13YO DEVELOPER" >> $LOG_FILE
    echo "  Device: $DEVICE_NAME" >> $LOG_FILE
    echo "  Android: $ANDROID_VERSION" >> $LOG_FILE
    echo "  Started: $BUILD_DATE" >> $LOG_FILE
    echo "==============================================" >> $LOG_FILE
}

# Enhanced logging with fun emojis
log() {
    echo "[$(date '+%H:%M:%S')] 🚀 $1" >> $LOG_FILE
}

log_error() {
    echo "[$(date '+%H:%M:%S')] ❌ ERROR: $1" >> $LOG_FILE
}

log_success() {
    echo "[$(date '+%H:%M:%S')] ✅ $1" >> $LOG_FILE
}

log_info() {
    echo "[$(date '+%H:%M:%S')] ℹ️  $1" >> $LOG_FILE
}

# Smart boot waiting with progress
wait_until_boot_complete() {
    log "Waiting for system to fully boot..."
    local count=0
    while [ "$(getprop sys.boot_completed)" != "1" ]; do
        sleep 3
        count=$((count + 1))
        if [ $count -gt 50 ]; then
            log_error "Boot wait timeout! Continuing anyway..."
            break
        fi
    done
    sleep 8  # Extra safety for services to start
    log_success "System boot completed!"
}

# ====================
# SAMSUNG S22 SPECIAL OPTIMIZATIONS
# ====================
apply_samsung_s22_optimizations() {
    log "Applying Samsung Galaxy S22 special optimizations..."
    
    # Exynos 2200 specific optimizations
    if [ -d "/sys/devices/system/cpu/cpu0/cpufreq" ]; then
        # CPU boost control
        echo "0" > /sys/devices/system/cpu/cpufreq/max_cpu_boost 2>/dev/null
        echo "0" > /sys/module/msm_performance/parameters/touchboost 2>/dev/null
        
        # GPU optimization for Xclipse 920
        if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
            echo "0" > /sys/class/kgsl/kgsl-3d0/max_pwrlevel 2>/dev/null
            echo "0" > /sys/class/kgsl/kgsl-3d0/min_pwrlevel 2>/dev/null
            echo "1" > /sys/class/kgsl/kgsl-3d0/force_no_nap 2>/dev/null
            echo "0" > /sys/class/kgsl/kgsl-3d0/force_bus_on 2>/dev/null
            echo "0" > /sys/class/kgsl/kgsl-3d0/force_clk_on 2>/dev/null
            echo "0" > /sys/class/kgsl/kgsl-3d0/force_rail_on 2>/dev/null
        fi
    fi
    
    # Samsung display optimizations
    if [ -f "/sys/class/lcd/panel/smart_on" ]; then
        echo "0" > /sys/class/lcd/panel/smart_on 2>/dev/null
    fi
    
    # Samsung battery optimizations
    if [ -f "/sys/class/sec/charger/charging_enabled" ]; then
        echo "1" > /sys/class/sec/charger/charging_enabled 2>/dev/null
    fi
    
    log_success "Samsung S22 optimizations applied!"
}

# ====================
# UNIVERSAL OPTIMIZATIONS (Works on ALL devices)
# ====================
apply_universal_optimizations() {
    log "Applying universal optimizations for all devices..."
    
    # SMART CPU GOVERNOR - Auto-detects best governor
    detect_and_set_governor() {
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
            if [ -d "$cpu" ]; then
                # Try schedutil first (modern), then interactive (older devices)
                if grep -q "schedutil" "$cpu/scaling_available_governors" 2>/dev/null; then
                    echo "schedutil" > "$cpu/scaling_governor" 2>/dev/null
                    log "CPU: Set schedutil governor"
                elif grep -q "interactive" "$cpu/scaling_available_governors" 2>/dev/null; then
                    echo "interactive" > "$cpu/scaling_governor" 2>/dev/null
                    log "CPU: Set interactive governor"
                elif grep -q "ondemand" "$cpu/scaling_available_governors" 2>/dev/null; then
                    echo "ondemand" > "$cpu/scaling_governor" 2>/dev/null
                    log "CPU: Set ondemand governor"
                fi
            fi
        done
    }
    
    detect_and_set_governor
    
    # MEMORY OPTIMIZATIONS
    echo "10" > /proc/sys/vm/dirty_ratio
    echo "5" > /proc/sys/vm/dirty_background_ratio
    echo "3000" > /proc/sys/vm/dirty_expire_centisecs
    echo "500" > /proc/sys/vm/dirty_writeback_centisecs
    echo "100" > /proc/sys/vm/swappiness
    echo "0" > /proc/sys/vm/oom_kill_allocating_task
    echo "1" > /proc/sys/vm/overcommit_memory
    
    # I/O SCHEDULER - Smart detection
    for block in /sys/block/*/queue; do
        if [ -d "$block" ]; then
            if grep -q "cfq" "$block/scheduler" 2>/dev/null; then
                echo "cfq" > "$block/scheduler" 2>/dev/null
            elif grep -q "mq-deadline" "$block/scheduler" 2>/dev/null; then
                echo "mq-deadline" > "$block/scheduler" 2>/dev/null
            elif grep -q "noop" "$block/scheduler" 2>/dev/null; then
                echo "noop" > "$block/scheduler" 2>/dev/null
            fi
            echo "128" > "$block/read_ahead_kb" 2>/dev/null
        fi
    done
    
    # NETWORK OPTIMIZATIONS
    echo "bbr" > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null
    echo "4096 87380 6291456" > /proc/sys/net/ipv4/tcp_rmem
    echo "4096 16384 4194304" > /proc/sys/net/ipv4/tcp_wmem
    echo "1" > /proc/sys/net/ipv4/tcp_tw_reuse
    echo "1" > /proc/sys/net/ipv4/tcp_sack
    echo "1" > /proc/sys/net/ipv4/tcp_fack
    
    log_success "Universal optimizations applied!"
}

# ====================
# GAMING PERFORMANCE MODE
# ====================
apply_gaming_optimizations() {
    log "Applying gaming performance mode..."
    
    # Maximum CPU performance
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
        if [ -f "$cpu/scaling_max_freq" ]; then
            local max_freq=$(cat "$cpu/cpuinfo_max_freq" 2>/dev/null)
            echo "$max_freq" > "$cpu/scaling_max_freq" 2>/dev/null
        fi
        if [ -f "$cpu/scaling_min_freq" ]; then
            local min_freq=$(cat "$cpu/cpuinfo_min_freq" 2>/dev/null)
            echo "$min_freq" > "$cpu/scaling_min_freq" 2>/dev/null
        fi
    done
    
    # GPU to maximum performance
    for gpu in /sys/class/kgsl/kgsl-3d0; do
        if [ -d "$gpu" ]; then
            echo "0" > "$gpu/min_pwrlevel" 2>/dev/null
            echo "0" > "$gpu/max_pwrlevel" 2>/dev/null
        fi
    done
    
    # Disable thermal throttling slightly (be careful!)
    for thermal in /sys/class/thermal/thermal_zone*/policy; do
        if [ -f "$thermal" ]; then
            echo "step_wise" > "$thermal" 2>/dev/null
        fi
    done
    
    log_success "Gaming mode activated!"
}

# ====================
# BATTERY SAVER MODE
# ====================
apply_battery_saver_optimizations() {
    log "Applying battery saver mode..."
    
    # Limit CPU frequencies
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
        if [ -f "$cpu/scaling_max_freq" ]; then
            local max_freq=$(cat "$cpu/cpuinfo_max_freq" 2>/dev/null)
            local battery_max=$((max_freq * 70 / 100))  # 70% of max
            echo "$battery_max" > "$cpu/scaling_max_freq" 2>/dev/null
        fi
    done
    
    # Enable power-efficient workqueues
    echo "1" > /sys/module/workqueue/parameters/power_efficient 2>/dev/null
    
    # Reduce GPU power
    for gpu in /sys/class/kgsl/kgsl-3d0; do
        if [ -d "$gpu" ]; then
            echo "5" > "$gpu/min_pwrlevel" 2>/dev/null
            echo "5" > "$gpu/max_pwrlevel" 2>/dev/null
        fi
    done
    
    log_success "Battery saver mode activated!"
}

# ====================
# ANDROID SYSTEM TWEAKS
# ====================
apply_android_tweaks() {
    log "Applying Android system tweaks..."
    
    # Disable animations for better performance
    settings put global window_animation_scale 0.3
    settings put global transition_animation_scale 0.3
    settings put global animator_duration_scale 0.3
    
    # Enable aggressive doze
    settings put global device_idle_constants light_after_inactive_to=15000,light_pre_idle_to=30000,light_idle_to=1800000,light_idle_factor=2
    
    # Background process limit
    settings put global background_process_limit 2
    
    # Disable unnecessary services
    settings put global package_verifier_enable 0
    settings put global development_settings_enabled 1
    
    # Enable GPU rendering for 2D operations
    settings put global enable_gpu_debug_layers 0
    settings put global debug.hwui.renderer opengl
    
    log_success "Android tweaks applied!"
}

# ====================
# BUILD.PROP OPTIMIZATIONS
# ====================
apply_buildprop_tweaks() {
    log "Applying build.prop optimizations..."
    
    # Performance tweaks
    resetprop ro.config.hw_quickpoweron true
    resetprop ro.kernel.android.checkjni 0
    resetprop debug.performance.tuning 1
    resetprop video.accelerate.hw 1
    resetprop persist.sys.composition.type gpu
    
    # Battery saving tweaks
    resetprop wifi.supplicant_scan_interval 300
    resetprop ro.ril.disable.power.collapse 0
    resetprop pm.sleep_mode 1
    
    # Dalvik/ART optimizations
    resetprop dalvik.vm.checkjni false
    resetprop dalvik.vm.dexopt-flags m=y,o=v,u=y
    resetprop dalvik.vm.execution-mode int:fast
    resetprop dalvik.vm.image-dex2oat-filter speed
    resetprop dalvik.vm.dex2oat-filter speed
    
    # Graphics optimizations
    resetprop ro.min.fling_velocity 0
    resetprop ro.max.fling_velocity 20000
    resetprop persist.sys.scrollingcache 3
    
    log_success "Build.prop tweaks applied!"
}

# ====================
# SMART AUTO-MODE DETECTION
# ====================
apply_smart_auto_mode() {
    log "Detecting best optimization mode..."
    
    # Check if charger is connected
    local battery_status=$(dumpsys battery | grep "status:" | awk '{print $2}')
    local ac_connected=$(dumpsys battery | grep "AC powered:" | awk '{print $3}')
    
    if [ "$ac_connected" = "true" ] || [ "$battery_status" = "2" ]; then
        log "Charger connected - Applying PERFORMANCE MODE!"
        apply_gaming_optimizations
    else
        local battery_level=$(dumpsys battery | grep "level:" | awk '{print $2}')
        if [ "$battery_level" -lt 30 ]; then
            log "Battery low ($battery_level%) - Applying ULTRA BATTERY SAVER!"
            apply_battery_saver_optimizations
        else
            log "Normal usage - Applying BALANCED MODE!"
            # Balanced mode is the default universal optimizations
        fi
    fi
}

# ====================
# MAIN OPTIMIZATION CONTROLLER
# ====================
main_optimization() {
    log "🚀 STARTING ULTIMATE OPTIMIZER v2.0"
    log "👦 Developed by 13-year-old coder!"
    log "📱 Primary device: Samsung S22 SM-S901B"
    log "🤖 Android: $ANDROID_VERSION | Device: $DEVICE_NAME"
    
    # Wait for full boot
    wait_until_boot_complete
    
    # Apply optimizations in sequence with cool emojis
    log "🔧 Starting optimization process..."
    
    apply_universal_optimizations
    sleep 1
    
    # Check if this is a Samsung S22
    if echo "$DEVICE_NAME" | grep -qi "SM-S901B"; then
        log "📱 Samsung S22 detected! Applying special optimizations!"
        apply_samsung_s22_optimizations
    else
        log "📱 Other device detected: $DEVICE_NAME - Using universal optimizations"
    fi
    sleep 1
    
    apply_smart_auto_mode
    sleep 1
    
    apply_android_tweaks
    sleep 1
    
    apply_buildprop_tweaks
    
    # Final completion message
    log_success "🎉 ULTIMATE OPTIMIZATION COMPLETED!"
    log_success "🌟 Hope this makes your phone faster and battery better!"
    log_success "💻 This is my first public release - Enjoy! - 13yo Developer"
    
    # Create completion marker
    touch /data/media/0/.optimization_complete_v2
    echo "Optimized by Ultimate Optimizer v2.0 - 13yo Developer" > /data/media/0/optimizer_info.txt
    echo "Device: $DEVICE_NAME" >> /data/media/0/optimizer_info.txt
    echo "Android: $ANDROID_VERSION" >> /data/media/0/optimizer_info.txt
    echo "Date: $BUILD_DATE" >> /data/media/0/optimizer_info.txt
}

# ====================
# SERVICE STARTUP
# ====================
# Initialize logging
print_banner

# Check if this is first run or update
if [ ! -f /data/media/0/.optimization_complete_v2 ]; then
    log "🎯 First run detected! Starting fresh optimization..."
    main_optimization &
else
    log "🔄 Optimization already applied, running maintenance..."
    # Just apply critical optimizations that might reset
    apply_universal_optimizations
    apply_smart_auto_mode
fi

# Keep service alive and re-apply every hour
while true; do
    sleep 3600  # 1 hour
    log "🔄 Running periodic optimization refresh..."
    apply_smart_auto_mode
    apply_universal_optimizations
done