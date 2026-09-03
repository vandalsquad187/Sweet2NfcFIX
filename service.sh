#!/system/bin/sh
MODDIR=${0%/*}
LOG=/data/local/tmp/nfc_fix.log
echo "[$(date '+%H:%M:%S')] service start (v3.2)" >> "$LOG" 2>/dev/null
if [ -e /dev/nq-nci ]; then
    ln -sf /dev/nq-nci /dev/nxp-nci 2>/dev/null
    chown nfc:nfc /dev/nq-nci 2>/dev/null; chmod 660 /dev/nq-nci 2>/dev/null
    chown root:root /dev/nxp-nci 2>/dev/null; chmod 666 /dev/nxp-nci 2>/dev/null
    chcon u:object_r:nfc_device:s0 /dev/nxp-nci 2>/dev/null; restorecon /dev/nxp-nci 2>/dev/null
    echo "[$(date '+%H:%M:%S')] service: symlink /dev/nxp-nci done" >> "$LOG" 2>/dev/null
fi
CHOSEN="/data/local/tmp/libnfc-nxp.chosen.conf"
if [ ! -f "$CHOSEN" ]; then
    CHOICE=$(cat /data/local/tmp/nfc_fix.choice 2>/dev/null); [ -z "$CHOICE" ] && CHOICE="sweet2-fix"
    SRC="$MODDIR/system/vendor/etc/libnfc-nxp.conf.$CHOICE"
    [ -f "$SRC" ] || SRC="$MODDIR/system/vendor/etc/libnfc-nxp.conf.sweet2-fix"
    cp -f "$SRC" "$CHOSEN" 2>/dev/null
    echo "[$(date '+%H:%M:%S')] service: chose $CHOICE" >> "$LOG" 2>/dev/null
fi
dobind() {
    local src="$1" dst="$2"
    [ -f "$src" ] || { echo "[$(date '+%H:%M:%S')] service: SKIP $dst (no src)" >> "$LOG" 2>/dev/null; return 1; }
    [ -e "$dst" ] || { echo "[$(date '+%H:%M:%S')] service: SKIP $dst (no target)" >> "$LOG" 2>/dev/null; return 1; }
    if mountpoint -q "$dst" 2>/dev/null; then
        echo "[$(date '+%H:%M:%S')] service: SKIP $dst (already mounted)" >> "$LOG" 2>/dev/null
        return 0
    fi
    if mount --bind "$src" "$dst" 2>/dev/null; then
        echo "[$(date '+%H:%M:%S')] service: bind OK $dst" >> "$LOG" 2>/dev/null
    else
        echo "[$(date '+%H:%M:%S')] service: bind FAIL $dst" >> "$LOG" 2>/dev/null
    fi
}
if [ -f "$CHOSEN" ]; then
    dobind "$CHOSEN" /vendor/etc/libnfc-nxp.conf
    chcon u:object_r:vendor_configs_file:s0 /vendor/etc/libnfc-nxp.conf 2>/dev/null; restorecon /vendor/etc/libnfc-nxp.conf 2>/dev/null
    dobind "$MODDIR/system/vendor/etc/libnfc-nxp_RF.conf" /vendor/etc/libnfc-nxp_RF.conf
fi
if getprop init.svc.vendor.nfc_hal_service 2>/dev/null | grep -q running; then
    setprop ctl.restart vendor.nfc_hal_service 2>/dev/null && echo "[$(date '+%H:%M:%S')] service: restart vendor.nfc_hal_service" >> "$LOG" 2>/dev/null
else
    echo "[$(date '+%H:%M:%S')] service: nfc_hal not running, no restart" >> "$LOG" 2>/dev/null
fi
