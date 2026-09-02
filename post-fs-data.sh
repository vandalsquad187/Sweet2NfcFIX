#!/system/bin/sh
MODDIR=${0%/*}
LOG=/data/local/tmp/nfc_fix.log
echo "[$(date '+%H:%M:%S')] post-fs-data start" >> "$LOG" 2>/dev/null
HW=$(getprop ro.boot.hwc 2>/dev/null); PROD=$(getprop ro.product.name 2>/dev/null); DEV=$(getprop ro.product.device 2>/dev/null)
CHOICE="sweet2-fix"
case "$PROD|$HW|$DEV" in
    *sweet2*|*rubens*|*Global*lot*) CHOICE="sweet2-fix" ;;
    *sweet*|*curtana*|*excalibur*|*joyeuse*) 
        # sweet non-2 keeps stock (0x85) for lottery losers; sweet2 needs fix
        case "$PROD" in *sweet2*) CHOICE="sweet2-fix";; *) CHOICE="sweet2-stock";; esac
        ;;
    *) CHOICE="sweet2-fix" ;;
esac
# also allow override via prop
OVR=$(getprop persist.nfc.sweet2.conf 2>/dev/null)
case "$OVR" in fix) CHOICE="sweet2-fix";; stock) CHOICE="sweet2-stock";; esac
echo "[$(date '+%H:%M:%S')] post-fs-data: auto choice $CHOICE (PROD=$PROD HW=$HW OVR=$OVR)" >> "$LOG" 2>/dev/null
SRC="$MODDIR/system/vendor/etc/libnfc-nxp.conf.$CHOICE"
if [ ! -f "$SRC" ]; then SRC="$MODDIR/system/vendor/etc/libnfc-nxp.conf.sweet2-fix"; fi
# wait for nq-nci
i=0; while [ ! -e /dev/nq-nci ] && [ $i -lt 25 ]; do sleep 0.2; i=$((i+1)); done
if [ ! -e /dev/nq-nci ]; then echo "[$(date '+%H:%M:%S')] post-fs-data: /dev/nq-nci not found" >> "$LOG" 2>/dev/null; exit 0; fi
# choose conf -> tmp for service to bind
mkdir -p /data/local/tmp 2>/dev/null
cp -f "$SRC" /data/local/tmp/libnfc-nxp.chosen.conf 2>/dev/null
echo "$CHOICE" > /data/local/tmp/nfc_fix.choice 2>/dev/null
ln -sf /dev/nq-nci /dev/nxp-nci 2>/dev/null
chown nfc:nfc /dev/nq-nci 2>/dev/null; chmod 660 /dev/nq-nci 2>/dev/null
chown root:root /dev/nxp-nci 2>/dev/null; chmod 666 /dev/nxp-nci 2>/dev/null
chcon u:object_r:nfc_device:s0 /dev/nq-nci 2>/dev/null; chcon u:object_r:nfc_device:s0 /dev/nxp-nci 2>/dev/null; restorecon /dev/nq-nci /dev/nxp-nci 2>/dev/null
echo "[$(date '+%H:%M:%S')] post-fs-data: symlink /dev/nxp-nci + chose $CHOICE" >> "$LOG" 2>/dev/null
