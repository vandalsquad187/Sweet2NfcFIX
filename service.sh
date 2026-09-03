#!/system/bin/sh
# v3.3: main conf via static overlay (binds invisible to HAL ns), binds fallback only
MODDIR=${0%/*}
LOG=/data/local/tmp/nfc_fix.log
echo "[$(date '+%H:%M:%S')] service start (v1.4)" >> "$LOG" 2>/dev/null
if [ -e /dev/nq-nci ]; then
    ln -sf /dev/nq-nci /dev/nxp-nci 2>/dev/null
    chown nfc:nfc /dev/nq-nci 2>/dev/null; chmod 660 /dev/nq-nci 2>/dev/null
    chown root:root /dev/nxp-nci 2>/dev/null; chmod 666 /dev/nxp-nci 2>/dev/null
    chcon u:object_r:nfc_device:s0 /dev/nxp-nci 2>/dev/null; restorecon /dev/nxp-nci 2>/dev/null
    echo "[$(date '+%H:%M:%S')] service: symlink /dev/nxp-nci done" >> "$LOG" 2>/dev/null
fi
# static overlay provides fix conf to all namespaces; binds only fallback
dobind() {
    local src="$1" dst="$2"
    [ -f "$src" ] || return 1
    [ -e "$dst" ] || return 1
    mountpoint -q "$dst" 2>/dev/null && return 0
    mount --bind "$src" "$dst" 2>/dev/null && echo "[$(date '+%H:%M:%S')] service: bind OK $dst" >> "$LOG" 2>/dev/null
}
dobind "$MODDIR/system/vendor/etc/libnfc-nxp.conf" /vendor/etc/libnfc-nxp.conf
dobind "$MODDIR/system/vendor/etc/libnfc-nxp_RF.conf" /vendor/etc/libnfc-nxp_RF.conf
chcon u:object_r:vendor_configs_file:s0 /vendor/etc/libnfc-nxp.conf 2>/dev/null; restorecon /vendor/etc/libnfc-nxp.conf 2>/dev/null
if getprop init.svc.vendor.nfc_hal_service 2>/dev/null | grep -q running; then
    setprop ctl.restart vendor.nfc_hal_service 2>/dev/null && echo "[$(date '+%H:%M:%S')] service: restart vendor.nfc_hal_service" >> "$LOG" 2>/dev/null
else
    echo "[$(date '+%H:%M:%S')] service: nfc_hal not running, no restart" >> "$LOG" 2>/dev/null
fi
