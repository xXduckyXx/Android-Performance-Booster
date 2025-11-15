#!/system/bin/sh
# MODIFY AND USING AT YOUR OWN RISK 
# Magisk module installation script

ui_print "********************************"
ui_print "Performance & Battery Optimizer"
ui_print "********************************"
ui_print "Comprehensive optimization for Android 13/14/15"
ui_print "Optimizing performance and battery life..."
ui_print " "

# Set module permissions
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/service.sh 0 0 0755

ui_print "Installation completed!"
ui_print "Reboot to apply optimizations."