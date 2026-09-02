#!/system/bin/sh
MODDIR=${0%/*}
LOG=/data/local/tmp/nfc_fix.log
echo "[$(date '+%H:%M:%S')] service start" >> "$LOG" 2>/dev/null
if [ -e /dev/nq-nci ]; then
    ln -sf /dev/nq-nci /dev/nxp-nci 2>/dev/null
    chown nfc:nfc /dev/nq-nci 2>/dev/null; chmod 660 /dev/nq-nci 2>/dev/null
    chown root:root /dev/nxp-nci 2>/dev/null; chmod 666 /dev/nxp-nci 2>/dev/null
    chcon u:object_r:nfc_device:s0 /dev/nxp-nci 2>/dev/null; restorecon /dev/nxp-nci 2>/dev/null
fi
CHOSEN="/data/local/tmp/libnfc-nxp.chosen.conf"
if [ ! -f "$CHOSEN" ]; then
    CHOICE=$(cat /data/local/tmp/nfc_fix.choice 2>/dev/null); [ -z "$CHOICE" ] && CHOICE="sweet2-fix"
    SRC="$MODDIR/system/vendor/etc/libnfc-nxp.conf.$CHOICE"
    [ -f "$SRC" ] || SRC="$MODDIR/system/vendor/etc/libnfc-nxp.conf.sweet2-fix"
    cp -f "$SRC" "$CHOSEN" 2>/dev/null
fi
if [ -f "$CHOSEN" ]; then
    mkdir -p /system/vendor 2>/dev/null
    mount --bind "$CHOSEN" /vendor/etc/libnfc-nxp.conf 2>/dev/null && echo "[$(date '+%H:%M:%S')] service: bind /vendor/etc/libnfc-nxp.conf ($CHOICE)" >> "$LOG" 2>/dev/null
    mount --bind "$CHOSEN" /system/vendor/etc/libnfc-nxp.conf 2>/dev/null
    mount --bind "$CHOSEN" /system/vendor/libnfc-nxp.conf 2>/dev/null
    # also ensure etc path for HAL fallback
    [ -f "$MODDIR/system/vendor/etc/libnfc-nxp_RF.conf" ] && mount --bind "$MODDIR/system/vendor/etc/libnfc-nxp_RF.conf" /vendor/etc/libnfc-nxp_RF.conf 2>/dev/null
    [ -f "$MODDIR/system/vendor/libnfc-nxp_RF.conf" ] && mount --bind "$MODDIR/system/vendor/libnfc-nxp_RF.conf" /system/vendor/libnfc-nxp_RF.conf 2>/dev/null
    chcon u:object_r:vendor_configs_file:s0 /vendor/etc/libnfc-nxp.conf 2>/dev/null; restorecon /vendor/etc/libnfc-nxp.conf 2>/dev/null
fi
setprop ctl.restart vendor.nfc_hal_service 2>/dev/null && echo "[$(date '+%H:%M:%S')] service: restart vendor.nfc_hal_service" >> "$LOG" 2>/dev/null
